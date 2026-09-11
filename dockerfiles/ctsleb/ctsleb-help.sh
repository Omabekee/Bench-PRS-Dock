#!/bin/sh
# /usr/local/bin/ctsleb-help - usage helper (default CMD of chiomab/ctsleb:v2.1)
# Description/inputs quoted verbatim from the CT-SLEB README (github.com/andrewhaoyu/CTSLEB).
cat <<'EOF'
==================================================================
 CT-SLEB
==================================================================
DESCRIPTION  (from the CT-SLEB README)
  "CT-SLEB is a method designed to generate multi-ancestry PRSs that
   incorporate existing large GWAS from EUR populations and smaller GWAS
   from non-EUR populations. The method has three key steps:
     1. Clumping and Thresholding for selecting SNPs to be included in a
        PRS for the target population;
     2. Empirical-Bayes method for estimating the coefficients of the SNPs;
     3. Super-learning model to combine a series of PRSs generated under
        different SNP selection thresholds."
  Reference: Zhang, H., Zhan, J., Jin, J., Zhang, J., Lu, W., Zhao, R.,
   ..., & Chatterjee, N. (2023). A new method for multiancestry polygenic
   prediction improves performance across diverse populations.
   Nature Genetics, 55(10), 1757-1768.

INPUT FILES  (from the CT-SLEB README)
  "GWAS summary statistics from training datasets across EUR and non-EUR
   populations", a "tuning dataset for the target population", and a
   "validation dataset for the target population". Reference samples for
   the clumping step are required "for different populations" in
   "PLINK format".
  This image's runner consumes preprocessed sumstats with columns:
        CHR SNP BP A1 BETA SE P rs_id
  tuning/validation genotypes in PLINK 1 format, and per-population LD
  reference panels (PLINK 1 format).

RUN - bundled runner (run_ctsleb.R; arg-driven, seeded for reproducibility)
  Rscript /usr/local/bin/run_ctsleb.R \
      <sum_eur> <sum_afr> \
      <tune_plink> <valid_plink> \
      <eur_ref_prefix> <afr_ref_prefix> \
      <plink19> <plink2> \
      <out_dir> <seed>
    plink19 : /usr/local/bin/plink   plink2 : /usr/local/bin/plink2
    writes  : <out_dir>/test_individuals.tsv  (IID PHENO SCORE)

EXAMPLE  (bind-mount your data)
  docker run --rm \
    -v /path/sumstats:/in -v /path/geno:/geno -v /path/ldref:/ref \
    -v "$PWD/out":/work \
    chiomab/ctsleb:v2.1 \
    Rscript /usr/local/bin/run_ctsleb.R \
      /in/EUR_sumstats.txt /in/AFR_sumstats.txt \
      /geno/AFR_tune /geno/AFR_valid \
      /ref/EUR_chr /ref/AFR_chr \
      /usr/local/bin/plink /usr/local/bin/plink2 \
      /work 42

RUN - native CTSLEB R API  (see the CT-SLEB README/vignette)
  R> library(CTSLEB)
  R> # dimCT() -> CalculateEBEffectSize() -> PRS_Clean() -> SuperLearner()
  See github.com/andrewhaoyu/CTSLEB for the full function reference.

SELF-CHECK (verify the image's internal dependencies)
  docker run --rm chiomab/ctsleb:v2.1 goss -g /goss.yaml validate

TOOL      CT-SLEB  ·  https://github.com/andrewhaoyu/CTSLEB  ·  R 4.1.2, plink 1.9/2
IMAGE     chiomab/ctsleb:v2.1
MAINTAINER  Chioma Oselu  <chiomabonyido@gmail.com>  - questions / issues
          (upstream CT-SLEB: Haoyu Zhang <haoyu.zhang2@nih.gov>)
==================================================================
EOF
