#!/bin/sh
# /usr/local/bin/sdprx-help - usage helper (default CMD of chiomab/sdprx:v1.1)
# Description/inputs quoted verbatim from the SDPRX README (github.com/eldronzhou/SDPRX).
cat <<'EOF'
==================================================================
 SDPRX
==================================================================
DESCRIPTION  (from the SDPRX README)
  "SDPRX is a statistical method for cross-population prediction of
   complex traits. It integrates GWAS summary statistics and LD matrices
   from two populations (EUR and non-EUR) to compuate polygenic risk
   scores."
  Reference: Zhou G, Chen T, Zhao H. SDPRX: A statistical method for
   cross-population prediction of complex traits. Am J Hum Genet. 2023
   Jan 5;110(1):13-22.

INPUT FILES  (from the SDPRX README)
  Summary statistics (EUR and non-EUR), WITH header - at least:
        SNP     A1      A2      Z       N
  "where SNP is the marker name, A1 is the effect allele, A2 is the
   alternative allele, Z is the Z score for the association statistics,
   and N is the sample size."
  LD reference : the SDPRX EUR/non-EUR reference LD matrices (--load_ld).
  Validation   : target-sample .bim (--valid).
  Sample sizes : --N1 (EUR), --N2 (non-EUR).

RUN  (example from the SDPRX README)
  python /sdprx/SDPRX.py \
    --ss1 ${EUR_sumstats} --ss2 ${nonEUR_sumstats} \
    --N1 ${N_EUR} --N2 ${N_nonEUR} \
    --force_shared TRUE \
    --load_ld ${ld_dir} --valid ${target}.bim \
    --chr <CHR> --rho 0.8 \
    --out ${out_prefix}
    # writes : two files of adjusted effect sizes - <out>_1.txt (EUR),
    #          <out>_2.txt (non-EUR).

EXAMPLE  (bind-mount your data; SDPRX runs in the sdprx_env conda env)
  docker run --rm \
    -v /path/data:/data -v "$PWD/out":/out \
    chiomab/sdprx:v1.1 \
    bash -lc 'source /opt/conda/etc/profile.d/conda.sh && conda activate sdprx_env && \
      python /sdprx/SDPRX.py \
        --ss1 /data/EUR.txt --ss2 /data/AFR.txt --N1 208808 --N2 7472 \
        --force_shared TRUE --load_ld /data/ld --valid /data/AFR_geno.bim \
        --chr <CHR> --rho 0.8 --threads 4 --out /out/results_chr<CHR>'

SELF-CHECK (verify the image's internal dependencies)
  docker run --rm chiomab/sdprx:v1.1 goss -g /goss.yaml validate

TOOL      SDPRX  ·  https://github.com/eldronzhou/SDPRX  ·  Python 3.9 (sdprx_env)
IMAGE     chiomab/sdprx:v1.1
MAINTAINER  Chioma Oselu  <chiomabonyido@gmail.com>  - questions / issues
==================================================================
EOF
