#!/bin/sh
# /usr/local/bin/xpblup-help - usage helper (default CMD of chiomab/xpblup:v1.1)
# Description/usage quoted verbatim from the XP-BLUP README (github.com/tanglab/XP-BLUP).
cat <<'EOF'
==================================================================
 XP-BLUP
==================================================================
DESCRIPTION  (from the XP-BLUP README)
  "This script implements XP-BLUP, which improves complex traits
   prediction in minority populations by combining trans-ethnic and
   ethnic-specific information. It requires plink
   (https://www.cog-genomics.org/plink2 v1.90 or later) and gcta
   (http://cnsgenomics.com/software/gcta/, v1.25.3 or later)."
  "Please contact huatang@stanford.edu or hyfang@stanford.edu for
   questions or bug report."

USAGE  (from the XP-BLUP README)
  ./xpblup.sh [--help] [--plink=/usr/local/bin/plink] [--gcta=/usr/local/bin/gcta64] \
     [--pheno=./phenos/traindataN4k.pheno] \
     --train=./example_data/trainN4k --test=./example_data/testN2k \
     --snplist=./example_data/metaExtract.txt [--outdir=./output] [--outprefix=out]

OPTIONS  (from the XP-BLUP README)
  --plink=     PLINK location   (optional if plink is on PATH)
  --gcta=      GCTA location    (optional if gcta/gcta64 is on PATH)
  --pheno=     Phenotype file for train data (optional if in train .fam)
  --train=     Train data (Required; PLINK binary .bed/.bim/.fam)
  --test=      Test data  (Required; PLINK binary .bed/.bim/.fam)
  --snplist=   SNP list file defining SNP set C1 (Required)
  --outdir=    Output directory (Default: ./output)
  --outprefix= Output prefix    (Default: out)

EXAMPLE  (bind-mount your data; this image bundles plink + gcta64)
  docker run --rm \
    -v /path/data:/data -v "$PWD/out":/work \
    chiomab/xpblup:v1.1 \
    ./xpblup.sh \
      --plink=/usr/local/bin/plink --gcta=/usr/local/bin/gcta64 \
      --pheno=/data/train.pheno \
      --train=/data/trainN4k --test=/data/testN2k \
      --snplist=/data/metaExtract.txt \
      --outdir=/work --outprefix=xpblup
    # writes : <outdir>/<outprefix>.predict.profile
  # native tool help : docker run --rm chiomab/xpblup:v1.1 ./xpblup.sh --help

SELF-CHECK (verify the image's internal dependencies)
  docker run --rm chiomab/xpblup:v1.1 goss -g /goss.yaml validate

TOOL      XP-BLUP  ·  https://github.com/tanglab/XP-BLUP  ·  plink 1.9, gcta64
IMAGE     chiomab/xpblup:v1.1
MAINTAINER  Chioma Oselu  <chiomabonyido@gmail.com>  - questions / issues
          (upstream XP-BLUP: huatang@stanford.edu / hyfang@stanford.edu)
==================================================================
EOF
