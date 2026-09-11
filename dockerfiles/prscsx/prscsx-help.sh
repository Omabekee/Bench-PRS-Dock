#!/bin/sh
# /usr/local/bin/prscsx-help - usage helper (default CMD of chiomab/prscsx:v1.3)
# Description/inputs quoted verbatim from the PRS-CSx README (github.com/getian107/PRScsx).
cat <<'EOF'
==================================================================
 PRS-CSx
==================================================================
DESCRIPTION  (from the PRS-CSx README)
  "PRS-CSx is a Python based command line tool that integrates GWAS
   summary statistics and external LD reference panels from multiple
   populations to improve cross-population polygenic prediction.
   Posterior SNP effect sizes are inferred under coupled continuous
   shrinkage (CS) priors across populations."
  Reference: Y Ruan, YF Lin, YCA Feng, CY Chen, M Lam, Z Guo, et al.
   Improving polygenic prediction in ancestrally diverse populations.
   Nature Genetics, 54:573-580, 2022.

INPUT FILES  (from the PRS-CSx README)
  GWAS summary statistics - either BETA/OR + SE or BETA/OR + P,
  WITH header. BETA/OR + P format:
        SNP          A1   A2   BETA      P
        rs4970383    C    A    -0.0064   0.4778
        ...
  "where SNP is the rs ID, A1 is the effect allele, A2 is the
   alternative allele, BETA/OR is the effect/odds ratio of the A1
   allele, P is the p-value of the effect."
  LD reference panels : the PRS-CSx 1KG or UKBB panels + SNP info file.
  Validation bim      : --bim_prefix (target-sample .bim).
  Per-population GWAS sample size : --n_gwas.

RUN  (example from the PRS-CSx README)
  python /PRS-CSx/PRScsx.py \
    --ref_dir=${reference_path} \
    --bim_prefix=${bim_path}/${bim_prefix} \
    --sst_file=${EUR_sumstats},${AFR_sumstats} \
    --n_gwas=${N_EUR},${N_AFR} \
    --pop=EUR,AFR \
    --chrom=<CHR> \
    --phi=1e-04 \
    --out_dir=${outcome_path} \
    --out_name=my_prs
    # writes : ${out_name}_${pop}_pst_eff_a1_b0.5_phi..._chr${chrom}.txt
    #          (SNP BP A1 A2 posterior_beta)

EXAMPLE  (bind-mount your data; single chromosome)
  docker run --rm \
    -v /path/sumstats:/in -v /path/ldref:/ref -v "$PWD/out":/out \
    chiomab/prscsx:v1.3 \
    python /PRS-CSx/PRScsx.py \
      --ref_dir=/ref --bim_prefix=/ref/target \
      --sst_file=/in/EUR_sumstats.txt,/in/AFR_sumstats.txt \
      --n_gwas=208808,3140 --pop=EUR,AFR --chrom=<CHR> \
      --phi=1e-04 --out_dir=/out --out_name=my_prs --seed=42

SELF-CHECK (verify the image's internal dependencies)
  docker run --rm chiomab/prscsx:v1.3 goss -g /goss.yaml validate

TOOL      PRS-CSx  ·  https://github.com/getian107/PRScsx  ·  Python 3.8
IMAGE     chiomab/prscsx:v1.3
MAINTAINER  Chioma Oselu  <chiomabonyido@gmail.com>  - questions / issues
==================================================================
EOF
