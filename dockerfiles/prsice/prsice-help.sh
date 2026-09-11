#!/bin/sh
# /usr/local/bin/prsice-help  -  bundled usage helper (default CMD of chiomab/prsice:v1.1)
# Adapted from the PRSice-2 documentation (https://choishingwan.github.io/PRSice/).
cat <<'EOF'
==================================================================
 PRSice-2  -  Polygenic Risk Score via clumping + p-value thresholding
==================================================================
PURPOSE
  Computes a polygenic risk score from GWAS summary statistics on a
  target genotype cohort using clumping + p-value thresholding (C+T),
  and selects the best-fit p-value threshold against a phenotype.

RUN (inside this image)
  Rscript /usr/local/bin/PRSice.R \
      --dir           <workdir> \
      --prsice        /usr/local/bin/PRSice \
      --base          <GWAS_sumstats.txt> \
      --target        <plink_target_prefix> \
      --pheno         <phenotype.txt> \
      --pheno-col     PHENO \
      --binary-target T \
      --stat BETA --beta \
      --thread        4 \
      --out           <output_prefix>

REQUIRED INPUTS
  --base           GWAS summary statistics (needs SNP, A1, effect, P columns)
  --target         PLINK1 binary prefix (.bed/.bim/.fam) of target cohort
  --pheno          phenotype file:  FID  IID  PHENO ...
  --stat / --beta  effect column name + scale  (use --or for odds ratios)
  --binary-target  T = case/control, F = quantitative
  --prsice         path to the PRSice C++ binary (bundled at /usr/local/bin/PRSice)

OUTPUTS  (<output_prefix>.*)
  .best      per-individual best-fit PRS  (FID IID In_Regression PRS)
  .prsice    scores at every threshold tested
  .summary   best threshold + model fit stats
  .png       bar / high-res plots

EXAMPLE (bind-mount your data)
  docker run --rm \
    -v /path/sumstats.txt:/data/sumstats.txt \
    -v /path/geno_dir:/data/geno \
    -v /path/pheno.txt:/data/pheno.txt \
    -v "$PWD/out":/output \
    chiomab/prsice:v1.1 \
    Rscript /usr/local/bin/PRSice.R --dir /output \
      --prsice /usr/local/bin/PRSice --base /data/sumstats.txt \
      --target /data/geno/AFR_geno --pheno /data/pheno.txt \
      --pheno-col PHENO --binary-target T --stat BETA --beta \
      --thread 4 --out /output/PRSice

SELF-CHECK (verify the image's internal dependencies)
  docker run --rm chiomab/prsice:v1.1 goss -g /goss.yaml validate

VERSION   PRSice 2.3.5   (R 4.1.2, rocker/r-ver base)
DOCS      https://choishingwan.github.io/PRSice/
IMAGE     chiomab/prsice:v1.1
MAINTAINER  Chioma Oselu  <chiomabonyido@gmail.com>  - questions / issues
==================================================================
EOF
