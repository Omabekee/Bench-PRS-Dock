#!/bin/sh
# /usr/local/bin/xpass-help - usage helper (default CMD of chiomab/xpass:v1.4)
# Description/inputs/outputs quoted from the XPASS README (github.com/YangLabHKUST/XPASS).
cat <<'EOF'
==================================================================
 XPASS / XPASS+
==================================================================
DESCRIPTION  (from the XPASS README)
  "The XPASS package implements the XPASS approach for constructing PRS
   in an under-representated target population by leveraging Biobank-scale
   GWAS data in European populations."
  "XPASS+ allows the population-specific effects to be utilized in PRS
   construction."
  This single image serves both variants (pick one via the first argument
  of the bundled runner below).

INPUT FILES  (from the XPASS README)
  Summary statistics : five fields - SNP (rsid), N (sample size),
                       Z (Z-scores), A1 (effect allele), A2 (other allele)
  Reference panel    : plink 1 format (.bed/.bim/.fam)

RUN - bundled runner (run_xpass.R; this image's convenience wrapper around XPASS())
  Rscript /usr/local/bin/run_xpass.R \
      <xpass | xpass_plus> \
      <z1_target_sumstats> <z2_EUR_sumstats> \
      <ref1_target_LDref>  <ref2_EUR_LDref> \
      <pred_genotype> <pop> <sd_method> \
      <plink_bin | NA> <out_prefix>
    pop        : target population, e.g. AFR
    sd_method  : LD_block
    plink_bin  : /usr/local/bin/plink  (xpass_plus clumping)  |  NA  (xpass)
    writes     : <out>_mu.txt   <out>_PRS.txt   <out>_H.txt

RUN - native XPASS R API  (example from the XPASS README)
  R> library(XPASS)
  R> fit <- XPASS(file_z1=..., file_z2=..., file_ref1=..., file_ref2=...,
                  file_predGeno=..., compPRS=T, pop="EAS",
                  sd_method="LD_block", compPosMean=T, file_out="...")
  R> predict_XPASS(fit$mu, ref)
  R> evalR2_XPASS(fit$mu, sumstats_val, ref)
  Outputs (README): fit$H = "table of estimated heritabilities, co-heritability
     and genetic correlation"; fit$mu = "posterior means"; fit$PRS = "the PRS".
  See the README for the full XPASS() argument list.

EXAMPLE  (bind-mount your data; XPASS)
  docker run --rm \
    -v /path/sumstats:/in -v /path/ldref:/ref -v "$PWD/out":/out \
    chiomab/xpass:v1.4 \
    Rscript /usr/local/bin/run_xpass.R xpass \
      /in/AFR_sumstats.txt /in/EUR_sumstats.txt \
      /ref/AFR_pc_pruned2k /ref/EUR_pc_pruned2k /ref/AFR_pc_pruned2k \
      AFR LD_block NA /out/xpass
  # XPASS+ : first arg = xpass_plus ; plink_bin = /usr/local/bin/plink

SELF-CHECK (verify the image's internal dependencies)
  docker run --rm chiomab/xpass:v1.4 goss -g /goss.yaml validate

TOOL      XPASS  ·  https://github.com/YangLabHKUST/XPASS  ·  R 4.1.2, plink 1.9
IMAGE     chiomab/xpass:v1.4  (serves XPASS + XPASS+)
MAINTAINER  Chioma Oselu  <chiomabonyido@gmail.com>  - questions / issues
==================================================================
EOF
