#!/bin/sh
# /usr/local/bin/jointprs-help - usage helper (default CMD of chiomab/jointprs:v1.1)
# Description/inputs quoted verbatim from the JointPRS README (github.com/LeqiXu/JointPRS).
cat <<'EOF'
==================================================================
 JointPRS
==================================================================
DESCRIPTION  (from the JointPRS README)
  "JointPRS is a multi-population PRS model that only requires GWAS
   summary statistics and LD reference panels from multiple populations.
   When individual-level tuning data is available, it adopts a
   data-adaptive approach combining meta-analysis and tuning strategies."
  Reference: Xu, L., Zhou, G., Jiang, W., Zhang, H., Dong, Y., Guan, L.,
   & Zhao, H. (2025). JointPRS: a data-adaptive framework for
   multi-population genetic risk prediction incorporating genetic
   correlation. Nature Communications, 16, 3841.

  Two implementations (from the README):
    JointPRS-auto : no tuning data - computes the "auto" version directly
                    from GWAS summary statistics.
    JointPRS      : with tuning data - computes "meta" and "tune"
                    versions, then data-adaptively picks the optimal.

INPUT FILES  (from the JointPRS README)
  Summary statistics : five fields, WITH header -
        SNP    A1    A2    BETA    P
      SNP  : SNP rsID
      A1   : effect allele
      A2   : alternative allele
      BETA : effect size of allele A1 (direction of association only)
      P    : p-value (used to calculate the standardized effect size)
  LD reference panel : the PRS-CSx 1KG or UKBB panels + SNP info file
                       (github.com/getian107/PRScsx#getting-started)
  You also supply the per-population GWAS sample size (--n_gwas).

RUN - JointPRS-auto  (example from the JointPRS README)
  python /jointprs/JointPRS.py \
    --ref_dir=${reference_path} \
    --bim_prefix=${bim_path}/${bim_prefix} \
    --pop=EUR,AFR \
    --rho_cons=1,1 \
    --sst_file=${EUR_sumstats},${AFR_sumstats} \
    --n_gwas=${N_EUR},${N_AFR} \
    --chrom=<CHR> \
    --phi=1e-04 \
    --out_dir=${outcome_path} \
    --out_name=JointPRS_auto_EUR_AFR_11
    # --pop from {EUR,EAS,AFR,SAS,AMR}; --rho_cons=1,..=positive cross-pop
    #   correlation (default); =0,..=no correlation (PRS-CSx model, phi=1e-6).
    # --phi : global shrinkage prior, tune from {1e-6,1e-4,1e-2,1e0,auto}.
    # writes : ${out_name}_${pop}_..._chr${chrom}.txt  (SNP A1 A2 posterior betas)

EXAMPLE  (bind-mount your data; single chromosome)
  docker run --rm \
    -v /path/sumstats:/in -v /path/ldref:/ref -v "$PWD/out":/out \
    chiomab/jointprs:v1.1 \
    python /jointprs/JointPRS.py \
      --ref_dir=/ref --bim_prefix=/ref/target \
      --pop=EUR,AFR --rho_cons=1,1 \
      --sst_file=/in/EUR_sumstat.txt,/in/AFR_sumstat.txt \
      --n_gwas=208808,3140 --chrom=<CHR> --phi=1e-04 \
      --out_dir=/out --out_name=JointPRS_auto_EUR_AFR_11

SELF-CHECK (verify the image's internal dependencies)
  docker run --rm chiomab/jointprs:v1.1 goss -g /goss.yaml validate

TOOL      JointPRS  ·  https://github.com/LeqiXu/JointPRS  ·  Python 3.8, plink2
IMAGE     chiomab/jointprs:v1.1
MAINTAINER  Chioma Oselu  <chiomabonyido@gmail.com>  - questions / issues
==================================================================
EOF
