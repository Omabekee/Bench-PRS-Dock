# XPASS / XPASS+

**Image:** `chiomab/xpass:v1.4`  
**Method:** Bayesian hierarchical (shared and population-specific effects)  
**Authors:** Mingxuan Cai, Jiashun Xiao, Shunkang Zhang, Xiang Wan, Hongyu Zhao, Gang Chen, Can Yang  
**GitHub:** https://github.com/YangLabHKUST/XPASS  
**Paper:** [A unified framework for cross-population trait prediction by leveraging the genetic correlation of polygenic traits](https://doi.org/10.1016/j.ajhg.2021.03.002)

## Overview
XPASS constructs polygenic scores for an under-represented target population by leveraging large European GWAS data. XPASS+ additionally incorporates population-specific SNP effects. This single image serves both variants.

## Included software

| Component | Version |
|-----------|---------|
| R | 4.1.2 |
| R packages | XPASS, data.table, RhpcBLASctl, ieugwasr |
| Utilities | PLINK 1.9 |

## Pull the image
```bash
docker pull chiomab/xpass:v1.4
```

## Usage
The image bundles an executable usage helper, `xpass-help.sh` - a usage guide adapted from the tool's original GitHub repository - set as the default command, so it prints when you run the image with no arguments:
```bash
docker run --rm chiomab/xpass:v1.4
```
To run XPASS / XPASS+ on your own data, mount your input and output directories and call the tool:
```bash
docker run --rm \
  -v /path/sumstats:/in -v /path/ldref:/ref -v "$PWD/out":/out \
  chiomab/xpass:v1.4 \
  Rscript /usr/local/bin/run_xpass.R xpass \
    /in/AFR_sumstats.txt /in/EUR_sumstats.txt \
    /ref/AFR_ref /ref/EUR_ref /ref/AFR_ref AFR LD_block NA /out/xpass
```

## Self-check
```bash
docker run --rm chiomab/xpass:v1.4 goss -g /goss.yaml validate
```

## Citation
If you use this image, please cite the original method: [A unified framework for cross-population trait prediction by leveraging the genetic correlation of polygenic traits](https://doi.org/10.1016/j.ajhg.2021.03.002).

## Maintainer
Chioma Oselu - chiomabonyido@gmail.com  ·  Docker Hub: https://hub.docker.com/r/chiomab/xpass
