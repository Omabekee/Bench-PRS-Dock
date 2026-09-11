#!/usr/bin/env Rscript
# Obj1 XPASS / XPASS+ runner - arg-driven so the SAME script runs natively and in docker.
# Deterministic: BLAS/OMP pinned to 1 thread on both sides for byte-reproducible output (SHA check).
# Usage:
#   run_xpass.R <variant> <z1> <z2> <ref1> <ref2> <predGeno> <pop> <sd_method> <plink_bin> <out_prefix>
#     variant   : "xpass" | "xpass_plus"
#     z1/z2     : target / auxiliary sumstats (cols: SNP A1 A2 N Z)
#     ref1/ref2 : target / auxiliary LD-ref plink prefix (.bed/.bim/.fam)
#     predGeno  : prediction genotype plink prefix
#     pop       : target population (selects bundled LD-block file), e.g. "AFR"
#     plink_bin : path to plink 1.9 (for xpass_plus clumping; "NA" for xpass)
#     out_prefix: output prefix; writes <out>_mu.txt, <out>_PRS.txt, <out>_H.txt
suppressMessages({
  library(RhpcBLASctl); blas_set_num_threads(1); omp_set_num_threads(1)
  Sys.setenv(OMP_NUM_THREADS = "1", OPENBLAS_NUM_THREADS = "1", MKL_NUM_THREADS = "1")
  library(data.table); library(XPASS)
})

a <- commandArgs(trailingOnly = TRUE)
stopifnot(length(a) == 10)
variant <- a[1]; z1 <- a[2]; z2 <- a[3]; ref1 <- a[4]; ref2 <- a[5]
predGeno <- a[6]; pop <- a[7]; sd_method <- a[8]; plink_bin <- a[9]; out <- a[10]

snps_fe1 <- NULL; snps_fe2 <- NULL
if (variant == "xpass_plus") {
  suppressMessages(library(ieugwasr))
  clump <- function(zf, bfile) {
    d <- fread(zf)
    d$pval <- 2 * pnorm(-abs(d$Z))
    cl <- ld_clump(dplyr::tibble(rsid = d$SNP, pval = d$pval),
                   clump_kb = 250, clump_r2 = 0.1, clump_p = 0.05,
                   plink_bin = plink_bin, bfile = bfile)
    cl$rsid
  }
  snps_fe1 <- clump(z1, ref1)
  snps_fe2 <- clump(z2, ref2)
  cat(sprintf("[xpass_plus] FE SNPs: pop1=%d pop2=%d\n", length(snps_fe1), length(snps_fe2)))
}

fit <- XPASS(file_z1 = z1, file_z2 = z2, file_ref1 = ref1, file_ref2 = ref2,
             file_predGeno = predGeno, snps_fe1 = snps_fe1, snps_fe2 = snps_fe2,
             compPRS = TRUE, pop = pop, sd_method = sd_method, compPosMean = TRUE,
             file_out = out)

# Stable, deterministic artifacts for the native-vs-docker consistency check.
fwrite(fit$mu,  paste0(out, "_mu.txt"),  sep = "\t")
fwrite(fit$PRS, paste0(out, "_PRS.txt"), sep = "\t")
fwrite(fit$H,   paste0(out, "_H.txt"),   sep = "\t")
cat("[done] wrote", paste0(out, c("_mu.txt", "_PRS.txt", "_H.txt")), sep = "\n")
