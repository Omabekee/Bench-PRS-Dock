#!/bin/sh
# /usr/local/bin/bridgeprs-help - usage helper (default CMD of chiomab/bridgeprs:v1.6)
# Description/inputs quoted verbatim from the BridgePRS README (github.com/clivehoggart/BridgePRS).
cat <<'EOF'
==================================================================
 BridgePRS
==================================================================
DESCRIPTION  (from the BridgePRS README)
  "BridgePRS is an R and bash based package that integrates GWAS summary
   statistics from two populations. It was designed to improve prediction
   in a population for which GWASs are relatively under-powered
   (population 2) but there exist powerful GWAS data in another
   population (population 1). In addition to GWAS summary statistics,
   BridgePRS also requires genotype and phenotype data from the two
   populations for parameter optimisation (test data) and estimation of
   LD. ... Measures of model fit and SNP weights for the best model for
   population 2 are returned."
  Reference: Hoggart et al., Nature Genetics (2024),
   https://www.nature.com/articles/s41588-023-01583-9

INPUT FILES  (from the BridgePRS README)
  For each of the two populations: GWAS summary statistics, plus
  genotype and phenotype data (PLINK format) for parameter optimisation
  (test data) and LD estimation. Optional population-2 validation data
  enables out-of-sample prediction.

RUN - bundled launcher (/BridgePRS/bridgePRS)
  # 1) register each population, then 2) run the joint pipeline:
  /BridgePRS/bridgePRS tools check-pop -o <out> --pop EUR \
      --ld_path <ld> --sumstats_prefix <eur_ss> --sumstats_size <n_eur> \
      --genotype_prefix <eur_geno> --phenotype_file <eur_pheno>
  /BridgePRS/bridgePRS tools check-pop -o <out> --pop AFR \
      --ld_path <ld> --sumstats_prefix <afr_ss> --sumstats_size <n_afr> \
      --genotype_prefix <afr_geno> --phenotype_file <afr_pheno>
  /BridgePRS/bridgePRS pipeline go -o <out> \
      --config_files <out>/save/AFR.target.config <out>/save/EUR.base.config
    writes : prs-combined_AFR-EUR/AFR_weighted_combined_preds.dat
  # See /BridgePRS/bridgeExampleRun*.sh for complete worked examples.

EXAMPLE  (bind-mount your data; -o must be a WRITABLE mount)
  docker run --rm \
    -v /path/inputs:/in -v /path/ldref:/ld -v "$PWD/out":/work \
    chiomab/bridgeprs:v1.6 \
    bash -c '/BridgePRS/bridgePRS tools check-pop -o /work --pop EUR \
        --ld_path /ld --sumstats_prefix /in/EUR --sumstats_size 208808 \
        --genotype_prefix /in/EUR_geno --phenotype_file /in/EUR_pheno.txt && \
      /BridgePRS/bridgePRS tools check-pop -o /work --pop AFR ... && \
      /BridgePRS/bridgePRS pipeline go -o /work --config_files ...'

SELF-CHECK (verify the image's internal dependencies)
  docker run --rm chiomab/bridgeprs:v1.6 goss -g /goss.yaml validate

TOOL      BridgePRS  ·  https://github.com/clivehoggart/BridgePRS  ·  R 4.1.2, plink
IMAGE     chiomab/bridgeprs:v1.6
MAINTAINER  Chioma Oselu  <chiomabonyido@gmail.com>  - questions / issues
==================================================================
EOF
