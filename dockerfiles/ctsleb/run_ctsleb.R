#!/usr/bin/env Rscript
# Obj1 CT-SLEB runner - ARG-DRIVEN adaptation of
#   ql_eval_plan_new_obj/trancesprs/ctsleb/run_ctsleb_pcancer.R
# Changes vs the original (algorithm UNCHANGED):
#   (1) all hardcoded paths -> positional args (works in BOTH native and docker);
#   (2) set.seed(SEED) so SuperLearner/ranger/CV are reproducible -> native-vs-docker
#       consistency is meaningful (CT-SLEB is otherwise stochastic via SL.ranger);
#   (3) reads the preprocessed CT-SLEB sumstats (CHR SNP BP A1 BETA SE P rs_id);
#   (4) writes test_individuals.tsv (IID PHENO SCORE) = the consistency artifact.
# Pheno recode (fam V6==2 -> 1) is already internal (binary 0/1 for SuperLearner).
#
# Usage:
#   Rscript run_ctsleb.R <sum_eur> <sum_afr> <tune_plink> <valid_plink> \
#     <eur_ref_prefix> <afr_ref_prefix> <plink19> <plink2> <out_dir> <seed>

suppressMessages({
  library(CTSLEB); library(data.table); library(dplyr); library(caret)
  library(SuperLearner); library(ranger); library(glmnet); library(pROC)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 10) stop("need 10 args: sum_eur sum_afr tune_plink valid_plink eur_ref_prefix afr_ref_prefix plink19 plink2 out_dir seed")
EUR_sumstats_file <- args[[1]]
AFR_sumstats_file <- args[[2]]
tune_plinkfile    <- args[[3]]   # = AFR_seed44_valid (tuning)
valid_plinkfile   <- args[[4]]   # = AFR_seed44_test  (validation)
EUR_ref_prefix    <- args[[5]]   # e.g. .../EUR_ldref/EUR_chr
AFR_ref_prefix    <- args[[6]]   # e.g. .../AFR_ldref/AFR_chr
plink19_exec      <- args[[7]]
plink2_exec       <- args[[8]]
out_dir           <- args[[9]]
SEED              <- as.integer(args[[10]])

set.seed(SEED)  # reproducibility (SuperLearner + ranger + CV folds)

if (!grepl("/$", out_dir)) out_dir <- paste0(out_dir, "/")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(paste0(out_dir, "temp/"), showWarnings = FALSE)
dir.create(paste0(out_dir, "per_chr/"), showWarnings = FALSE)
cat("plink1.9:", plink19_exec, "\nplink2:  ", plink2_exec, "\nseed:", SEED, "\n")

# ============================================================
# Load and reformat summary statistics (prepro format: CHR SNP BP A1 BETA SE P rs_id)
# ============================================================
cat("\n=== Loading summary statistics ===\n")
sum_EUR_full <- fread(EUR_sumstats_file, header = TRUE)
sum_EUR_full <- sum_EUR_full[, .(CHR, SNP, BP, A1, BETA, SE, P, rs_id = SNP)]
cat("EUR sumstats:", nrow(sum_EUR_full), "SNPs\n")
sum_AFR_full <- fread(AFR_sumstats_file, header = TRUE)
sum_AFR_full <- sum_AFR_full[, .(CHR, SNP, BP, A1, BETA, SE, P, rs_id = SNP)]
cat("AFR sumstats:", nrow(sum_AFR_full), "SNPs\n")

# ============================================================
# Phenotypes (fam V6: 1=control, 2=case -> 0/1)
# ============================================================
cat("\n=== Extracting phenotypes ===\n")
tune_fam  <- fread(paste0(tune_plinkfile, ".fam"), header = FALSE)
valid_fam <- fread(paste0(valid_plinkfile, ".fam"), header = FALSE)
y_tune  <- data.table(V1 = as.integer(tune_fam$V6 == 2))
y_valid <- data.table(V1 = as.integer(valid_fam$V6 == 2))
cat("Tuning set:", nrow(tune_fam), "samples (", sum(y_tune$V1), "cases,", sum(y_tune$V1 == 0), "controls)\n")
cat("Validation set:", nrow(valid_fam), "samples (", sum(y_valid$V1), "cases,", sum(y_valid$V1 == 0), "controls)\n")
fwrite(y_tune,  paste0(out_dir, "y_tuning.txt"),     col.names = FALSE)
fwrite(y_valid, paste0(out_dir, "y_validation.txt"), col.names = FALSE)

# ============================================================
# CT-SLEB params
# ============================================================
PRS_farm <- SetParamsFarm(plink19_exec = plink19_exec, plink2_exec = plink2_exec)

# ============================================================
# Step 1: Per-chromosome dimCT (on merged tune+valid for scoring)
# ============================================================
cat("\n=== Step 1: Per-chromosome dimCT ===\n")
merged_plinkfile <- paste0(out_dir, "AFR_merged_tune_valid")
if (!file.exists(paste0(merged_plinkfile, ".bed"))) {
  cat("Merging tuning + validation genotype files...\n")
  system(paste0(plink19_exec, " --bfile ", tune_plinkfile, " --bmerge ", valid_plinkfile,
                " --make-bed --out ", merged_plinkfile, " --memory 8000 --threads 2"))
}
merged_fam <- fread(paste0(merged_plinkfile, ".fam"), header = FALSE)
n_tune <- nrow(tune_fam); n_valid <- nrow(valid_fam); n_total <- nrow(merged_fam)
cat("Merged file:", n_total, "samples (tune:", n_tune, "+ valid:", n_valid, ")\n")

# plink --bmerge sorts samples; split tune/valid by ID
tune_idx  <- which(merged_fam$V1 %in% tune_fam$V1)
valid_idx <- which(merged_fam$V1 %in% valid_fam$V1)
cat("Tune indices in merged:", length(tune_idx), "/ Valid indices:", length(valid_idx), "\n")
y_combined <- data.table(V1 = as.integer(merged_fam$V6 == 2))
fwrite(y_combined, paste0(out_dir, "y_combined.txt"), col.names = FALSE)
y_tune_combined  <- y_combined[tune_idx]
y_valid_combined <- y_combined[valid_idx]

prs_mat_list <- list()
for (chr in 1:22) {
  cat("\n--- Chromosome", chr, "---\n")
  chr_out_dir <- paste0(out_dir, "per_chr/chr", chr, "/"); dir.create(chr_out_dir, showWarnings = FALSE)
  sum_EUR_chr <- sum_EUR_full[CHR == chr]; sum_AFR_chr <- sum_AFR_full[CHR == chr]
  cat("  EUR:", nrow(sum_EUR_chr), "SNPs, AFR:", nrow(sum_AFR_chr), "SNPs\n")
  if (nrow(sum_EUR_chr) == 0 | nrow(sum_AFR_chr) == 0) { cat("  Skipping chr", chr, "\n"); next }
  prs_mat_chr <- dimCT(results_dir = chr_out_dir, sum_target = sum_AFR_chr, sum_ref = sum_EUR_chr,
                       ref_plink = paste0(EUR_ref_prefix, chr), target_plink = paste0(AFR_ref_prefix, chr),
                       test_target_plink = merged_plinkfile, out_prefix = paste0("chr", chr),
                       params_farm = PRS_farm)
  cat("  prs_mat_chr dimensions:", dim(prs_mat_chr), "\n")
  prs_mat_list[[chr]] <- prs_mat_chr
}

# Combine per-chr PRS (sum across chr for each param combo)
cat("\n=== Combining per-chromosome PRS matrices ===\n")
first_chr <- prs_mat_list[[which(!sapply(prs_mat_list, is.null))[1]]]
sample_ids <- first_chr[, 1:2]; prs_colnames <- colnames(first_chr)[3:ncol(first_chr)]
prs_combined <- matrix(0, nrow = nrow(first_chr), ncol = length(prs_colnames)); colnames(prs_combined) <- prs_colnames
for (chr in 1:22) if (!is.null(prs_mat_list[[chr]])) {
  chr_prs <- as.matrix(prs_mat_list[[chr]][, 3:ncol(prs_mat_list[[chr]])])
  mc <- intersect(colnames(chr_prs), prs_colnames); prs_combined[, mc] <- prs_combined[, mc] + chr_prs[, mc]
}
prs_mat <- cbind(sample_ids, as.data.frame(prs_combined))

# Tune CT (Nagelkerke pseudo-R2)
cat("\n=== Tuning CT parameters ===\n")
prs_tune <- prs_mat[tune_idx, ]; n.total.prs <- ncol(prs_tune) - 2
prs_r2_vec_test <- rep(0, n.total.prs)
for (p_ind in 1:n.total.prs) tryCatch({
  model <- glm(y_tune_combined$V1 ~ prs_tune[, (2 + p_ind)], family = binomial())
  null_model <- glm(y_tune_combined$V1 ~ 1, family = binomial())
  prs_r2_vec_test[p_ind] <- 1 - exp((logLik(null_model) - logLik(model))[1] * 2 / n_tune)
}, error = function(e) { prs_r2_vec_test[p_ind] <<- 0 })
max_ind <- which.max(prs_r2_vec_test)
best_snps <- colnames(prs_tune)[max_ind + 2]
cat("Best CT config:", best_snps, " pseudo-R2:", prs_r2_vec_test[max_ind], "\n")

# ============================================================
# Step 2: Per-chromosome EB
# ============================================================
cat("\n=== Step 2: Per-chromosome EB ===\n")
prs_mat_eb_list <- list()
for (chr in 1:22) {
  cat("\n--- EB Chromosome", chr, "---\n")
  chr_out_dir <- paste0(out_dir, "per_chr/chr", chr, "/")
  sum_EUR_chr <- sum_EUR_full[CHR == chr]; sum_AFR_chr <- sum_AFR_full[CHR == chr]
  if (nrow(sum_EUR_chr) == 0 | nrow(sum_AFR_chr) == 0) { cat("  Skipping chr", chr, "\n"); next }
  prs_mat_chr <- dimCT(results_dir = chr_out_dir, sum_target = sum_AFR_chr, sum_ref = sum_EUR_chr,
                       ref_plink = paste0(EUR_ref_prefix, chr), target_plink = paste0(AFR_ref_prefix, chr),
                       test_target_plink = merged_plinkfile, out_prefix = paste0("chr", chr),
                       params_farm = PRS_farm)
  tryCatch({
    prs_mat_eb_chr <- CalculateEBEffectSize(bfile = merged_plinkfile, snp_ind = best_snps,
                                            plink_list = plink_list, out_prefix = paste0("chr", chr),
                                            results_dir = chr_out_dir, params_farm = PRS_farm)
    cat("  prs_mat_eb_chr dimensions:", dim(prs_mat_eb_chr), "\n")
    prs_mat_eb_list[[chr]] <- prs_mat_eb_chr
  }, error = function(e) {
    cat("  EB failed for chr", chr, ":", conditionMessage(e), "- using CT-only\n")
    prs_mat_eb_list[[chr]] <<- prs_mat_chr
  })
}

cat("\n=== Combining EB results ===\n")
first_eb <- prs_mat_eb_list[[which(!sapply(prs_mat_eb_list, is.null))[1]]]
sample_ids_eb <- first_eb[, 1:2]; eb_colnames <- colnames(first_eb)[3:ncol(first_eb)]
prs_eb_combined <- matrix(0, nrow = nrow(first_eb), ncol = length(eb_colnames)); colnames(prs_eb_combined) <- eb_colnames
for (chr in 1:22) if (!is.null(prs_mat_eb_list[[chr]])) {
  chr_eb <- as.matrix(prs_mat_eb_list[[chr]][, 3:ncol(prs_mat_eb_list[[chr]])])
  mc <- intersect(colnames(chr_eb), eb_colnames); if (length(mc) > 0) prs_eb_combined[, mc] <- prs_eb_combined[, mc] + chr_eb[, mc]
}
prs_mat_eb <- cbind(sample_ids_eb, as.data.frame(prs_eb_combined))

# ============================================================
# Step 3: Super Learning (binary)
# ============================================================
cat("\n=== Step 3: Super Learning ===\n")
prs_tune_eb <- prs_mat_eb[tune_idx, ]; prs_validation_eb <- prs_mat_eb[valid_idx, ]
Cleaned_Data <- PRS_Clean(Tune_PRS = prs_tune_eb, Tune_Y = y_tune_combined, Validation_PRS = prs_validation_eb)
prs_tune_sl <- Cleaned_Data$Cleaned_Tune_PRS; prs_valid_sl <- Cleaned_Data$Cleaned_Validation_PRS
sanitize_names <- function(df) { ids <- df[, 1:2]; prs <- df[, -c(1, 2)]; colnames(prs) <- make.names(colnames(prs), unique = TRUE); cbind(ids, prs) }
prs_tune_sl <- sanitize_names(prs_tune_sl); prs_valid_sl <- sanitize_names(prs_valid_sl)

sl <- SuperLearner(Y = y_tune_combined$V1, X = prs_tune_sl[, -c(1, 2)], family = binomial(),
                   SL.library = c("SL.glmnet", "SL.ranger"))
y_pred_valid <- predict(sl, prs_valid_sl[, -c(1, 2)], onlySL = TRUE)

y_valid_actual <- y_valid_combined$V1
roc_obj <- roc(y_valid_actual, as.numeric(y_pred_valid$pred), quiet = TRUE)
auc_ctsleb <- auc(roc_obj)
cat("\n*** CT-SLEB AUC on validation:", auc_ctsleb, "***\n")

# Consistency artifact: per-individual predictions
test_indiv <- data.frame(IID = prs_valid_sl$IID,
                         PHENO = ifelse(y_valid_actual == 1, 2, 1),
                         SCORE = as.numeric(y_pred_valid$pred))
fwrite(test_indiv, paste0(out_dir, "test_individuals.tsv"), sep = "\t")
cat("Saved test_individuals.tsv:", nrow(test_indiv), "rows\n")
cat("Done! CT-SLEB pipeline completed.\n")
