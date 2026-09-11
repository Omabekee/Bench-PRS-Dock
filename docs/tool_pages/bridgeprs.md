# BridgePRS

**Image:** `chiomab/bridgeprs:v1.6`  
**Method:** Bayesian ridge regression (three-stage)  
**Authors:** Clive J. Hoggart, Shing Wan Choi, Judit Garcia-Gonzalez, Tade Souaiaia, Michael Preuss, Paul F. O'Reilly  
**GitHub:** https://github.com/clivehoggart/BridgePRS  ·  **Website:** https://www.bridgeprs.net/  
**Paper:** [BridgePRS leverages shared genetic effects across ancestries to increase polygenic risk score portability](https://www.nature.com/articles/s41588-023-01583-9)

## Overview
BridgePRS integrates GWAS summary statistics from two populations to improve prediction in a population where GWAS is under-powered, using a three-stage Bayesian ridge regression.

## Included software

| Component | Version |
|-----------|---------|
| R | 4.1.2 |
| R packages | BEDMatrix, glmnet, MASS, data.table, optparse, doMC |
| Utilities | PLINK 1.9 |

## Pull the image
```bash
docker pull chiomab/bridgeprs:v1.6
```

## Usage
The image bundles an executable usage helper, `bridgeprs-help.sh` - a usage guide adapted from the tool's original GitHub repository - set as the default command, so it prints when you run the image with no arguments:
```bash
docker run --rm chiomab/bridgeprs:v1.6
```
To run BridgePRS on your own data, mount your input and output directories and call the tool:
```bash
docker run --rm \
  -v /path/inputs:/in -v /path/ldref:/ld -v "$PWD/out":/work \
  chiomab/bridgeprs:v1.6 \
  bash -c '/BridgePRS/bridgePRS tools check-pop -o /work --pop EUR \
      --ld_path /ld --sumstats_prefix /in/EUR --sumstats_size 208808 \
      --genotype_prefix /in/EUR_geno --phenotype_file /in/EUR_pheno.txt && \
    /BridgePRS/bridgePRS pipeline go -o /work --config_files ...'
```

## Self-check
```bash
docker run --rm chiomab/bridgeprs:v1.6 goss -g /goss.yaml validate
```

## Citation
If you use this image, please cite the original method: [BridgePRS leverages shared genetic effects across ancestries to increase polygenic risk score portability](https://www.nature.com/articles/s41588-023-01583-9).

## Maintainer
Chioma Oselu - chiomabonyido@gmail.com  ·  Docker Hub: https://hub.docker.com/r/chiomab/bridgeprs
