#!/bin/sh
# /usr/local/bin/tl-prs-help - usage helper (default CMD of chiomab/tl-prs:v1.3)
# Description/inputs quoted verbatim from the TL-PRS README (github.com/ZhangchenZhao/TLPRS).
cat <<'EOF'
==================================================================
 TL-PRS
==================================================================
DESCRIPTION  (from the TL-PRS README)
  "This R package helps users to construct multi-ethnic polygenic risk
   score (PRS) using transfer learning."
  Reference: Zhao, Z., Fritsche, L.G., Smith, J.A., Mukherjee, B. and
   Lee, S., 2022. The Construction of Multi-ethnic Polygenic Risk Score
   using Transfer Learning. medRxiv.

INPUT FILES  (from the TL-PRS README)
  Base/source summary statistics - columns 'SNP','A1','Beta':
     "'SNP' is the SNPID (the same format as SNPID in plink files); 'A1'
      is the alternative (effect) allele; 'Beta' is the effect size."
  Target-population summary statistics - columns 'SNP','A1','beta','N','p':
     "'beta' is the effect size ..., 'N' is the sample size ..., and 'p'
      is p-value of the SNP."
  ped file : "the information of FID, IID, outcome (Y) and covariates."
  Genotypes: PLINK train/test/scoring prefixes; LD blocks for lassosum.

RUN - bundled runner (run_tlprs.R; arg-driven; TL_PRS() then plink --score)
  Rscript /usr/local/bin/run_tlprs.R \
      <ped> <Covar_name> <Y_name> <Ytype> \
      <train> <test> <base_ss> <target_ss> \
      <LDblocks> <plink_bin> \
      <geno_for_score> <pheno_for_score> <out_prefix>
    plink_bin : /usr/local/bin/plink
    writes    : <out>_best.beta.txt (SNP A1 beta) + plink-scored profile

EXAMPLE  (bind-mount your data)
  docker run --rm \
    -v /path/data:/data -v "$PWD/out":/work \
    chiomab/tl-prs:v1.3 \
    Rscript /usr/local/bin/run_tlprs.R \
      /data/pheno.ped Covar Y binary \
      /data/train /data/test \
      /data/EUR_base_ss.txt /data/AFR_target_ss.txt \
      EUR /usr/local/bin/plink \
      /data/AFR_geno /data/AFR_pheno.txt /work/tlprs

RUN - native TLPRS R API  (see the TL-PRS README)
  R> library(TLPRS)
  R> TL_PRS(ped_file, Covar_name, Y_name, Ytype, train_file, test_file,
            sum_stats_file, target_sumstats_file, LDblocks, outfile, cluster)

SELF-CHECK (verify the image's internal dependencies)
  docker run --rm chiomab/tl-prs:v1.3 goss -g /goss.yaml validate

TOOL      TL-PRS  ·  https://github.com/ZhangchenZhao/TLPRS  ·  R 4.1.2, plink 1.9
IMAGE     chiomab/tl-prs:v1.3
MAINTAINER  Chioma Oselu  <chiomabonyido@gmail.com>  - questions / issues
          (upstream TL-PRS: Zhangchen Zhao <zczhao@umich.edu>)
==================================================================
EOF
