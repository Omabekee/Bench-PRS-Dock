#!/usr/bin/env Rscript
# Obj1 TL-PRS runner - arg-driven so the SAME script runs natively and in docker.
# Mirrors new_python_dev_nov/tlprs_pipeline.py (the verified existing runner): TL_PRS() then
# plink --score on the candidate betas. Single-thread BLAS/OMP (set via env in the caller) for
# reproducible docker-vs-native output.
# Usage:
#   run_tlprs.R <ped> <Covar_name> <Y_name> <Ytype> <train> <test> <base_ss> <target_ss> \
#               <LDblocks> <plink_bin> <geno_for_score> <pheno_for_score> <out_prefix>
#     base_ss   = source/EUR sumstats (TL_PRS arg `sum_stats_file`)        cols: SNP A1 beta
#     target_ss = target/AFR sumstats (TL_PRS arg `target_sumstats_file`)  cols: SNP A1 beta N p
#     train/test/geno_for_score = plink prefixes; ped + pheno carry FID IID Y [covars]
suppressMessages({ library(data.table); library(lassosum); library(TLPRS) })

a <- commandArgs(trailingOnly = TRUE)
stopifnot(length(a) == 13)
ped<-a[1]; covar<-a[2]; yname<-a[3]; ytype<-a[4]; train<-a[5]; test<-a[6]
base_ss<-a[7]; target_ss<-a[8]; ldblocks<-a[9]; plink_bin<-a[10]
geno_score<-a[11]; pheno_score<-a[12]; out<-a[13]

# TL_PRS(ped_file, Covar_name, Y_name, Ytype, train_file, test_file, sum_stats_file,
#        target_sumstats_file, LDblocks, outfile, cluster)
out.beta <- TL_PRS(ped, covar, yname, ytype, train, test, base_ss, target_ss,
                   ldblocks, out, cluster = NULL)

# plink scoring on the SELECTED TL-PRS model best.beta (cols SNP A1 beta, header) - this is the
# transfer-learned result. (NOT *_beta.candidates.txt, whose col3 is Beta2 = the initial base beta.)
cand <- Sys.glob(paste0(dirname(out), "/*_best.beta.txt"))
if (length(cand) < 1) stop("No *_best.beta.txt produced by TL_PRS")
score_file <- cand[1]
cmd <- sprintf("%s --bfile %s --score %s 1 2 3 header --pheno %s --allow-no-sex --out %s_scored",
               plink_bin, geno_score, score_file, pheno_score, out)
cat("[plink]", cmd, "\n"); rc <- system(cmd)
if (rc != 0) stop("plink scoring failed")
cat("[done] TL_PRS + plink scoring complete ->", paste0(out, "_scored.profile"), "\n")
