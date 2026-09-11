# PRSice-2

**Image:** `chiomab/prsice:v1.1`  
**Method:** Clumping and p-value thresholding (C+T)  
**Authors:** Shing Wan Choi, Paul F. O'Reilly  
**GitHub:** https://github.com/choishingwan/PRSice  ·  **Website:** https://choishingwan.github.io/PRSice/  
**Paper:** [PRSice-2: Polygenic Risk Score software for biobank-scale data](https://doi.org/10.1093/gigascience/giz082)

## Overview
PRSice-2 computes polygenic risk scores by clumping and p-value thresholding, and selects the best-fit p-value threshold against a target phenotype.

## Included software

| Component | Version |
|-----------|---------|
| PRSice-2 | 2.3.5 |
| R | 4.1.2 |
| R packages | data.table, ggplot2 |
| Utilities | PLINK 1.9 |

## Pull the image
```bash
docker pull chiomab/prsice:v1.1
```

## Usage
The image bundles an executable usage helper, `prsice-help.sh` - a usage guide adapted from the tool's original GitHub repository - set as the default command, so it prints when you run the image with no arguments:
```bash
docker run --rm chiomab/prsice:v1.1
```
To run PRSice-2 on your own data, mount your input and output directories and call the tool:
```bash
docker run --rm \
  -v /path/data:/data -v "$PWD/out":/output \
  chiomab/prsice:v1.1 \
  Rscript /usr/local/bin/PRSice.R --dir /output \
    --prsice /usr/local/bin/PRSice --base /data/sumstats.txt \
    --target /data/geno --pheno /data/pheno.txt --pheno-col PHENO \
    --binary-target T --stat BETA --beta --thread 4 --out /output/PRSice
```

## Self-check
```bash
docker run --rm chiomab/prsice:v1.1 goss -g /goss.yaml validate
```

## Citation
If you use this image, please cite the original method: [PRSice-2: Polygenic Risk Score software for biobank-scale data](https://doi.org/10.1093/gigascience/giz082).

## Maintainer
Chioma Oselu - chiomabonyido@gmail.com  ·  Docker Hub: https://hub.docker.com/r/chiomab/prsice
