# SDPRX

**Image:** `chiomab/sdprx:v1.1`  
**Method:** Nonparametric Bayesian mixture (cross-population)  
**Authors:** Geyu Zhou, Tianqi Chen, Hongyu Zhao  
**GitHub:** https://github.com/eldronzhou/SDPRX  
**Paper:** [SDPRX: A statistical method for cross-population prediction of complex traits](https://doi.org/10.1016/j.ajhg.2022.11.007)

## Overview
SDPRX integrates GWAS summary statistics and LD matrices from two populations to compute cross-population polygenic scores under a nonparametric Bayesian mixture model.

## Included software

| Component | Version |
|-----------|---------|
| SDPRX | (GitHub main) |
| Python | 3.9 |
| Python packages | numpy, scipy, pandas, joblib |
| Utilities | PLINK 1.9 |

## Pull the image
```bash
docker pull chiomab/sdprx:v1.1
```

## Usage
The image bundles an executable usage helper, `sdprx-help.sh` - a usage guide adapted from the tool's original GitHub repository - set as the default command, so it prints when you run the image with no arguments:
```bash
docker run --rm chiomab/sdprx:v1.1
```
To run SDPRX on your own data, mount your input and output directories and call the tool:
```bash
docker run --rm \
  -v /path/data:/data -v "$PWD/out":/out \
  chiomab/sdprx:v1.1 \
  bash -lc 'source /opt/conda/etc/profile.d/conda.sh && conda activate sdprx_env && \
    for c in $(seq 1 22); do python /sdprx/SDPRX.py \
      --ss1 /data/EUR.txt --ss2 /data/AFR.txt --N1 208808 --N2 7472 \
      --force_shared TRUE --load_ld /data/ld --valid /data/AFR_geno.bim \
      --chr $c --rho 0.8 --out /out/res_chr$c; done'
```

## Self-check
```bash
docker run --rm chiomab/sdprx:v1.1 goss -g /goss.yaml validate
```

## Citation
If you use this image, please cite the original method: [SDPRX: A statistical method for cross-population prediction of complex traits](https://doi.org/10.1016/j.ajhg.2022.11.007).

## Maintainer
Chioma Oselu - chiomabonyido@gmail.com  ·  Docker Hub: https://hub.docker.com/r/chiomab/sdprx
