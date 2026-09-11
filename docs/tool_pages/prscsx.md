# PRS-CSx

**Image:** `chiomab/prscsx:v1.3`  
**Method:** Bayesian continuous shrinkage (multi-ancestry)  
**Authors:** Yunfeng Ruan, Yen-Feng Lin, Yen-Chen A. Feng, Chia-Yen Chen, Max Lam, Zhenglin Guo, Lin He, Akira Sawa, Alicia R. Martin, Shengying Qin, Hailiang Huang, Tian Ge  
**GitHub:** https://github.com/getian107/PRScsx  
**Paper:** [Improving polygenic prediction in ancestrally diverse populations](https://www.nature.com/articles/s41588-022-01054-7)

## Overview
PRS-CSx integrates GWAS summary statistics and LD reference panels from multiple populations to improve cross-population polygenic prediction, using coupled continuous-shrinkage priors.

## Included software

| Component | Version |
|-----------|---------|
| PRS-CSx | 1.1.0 |
| Python | 3.8 |
| Python packages | numpy, scipy, h5py |
| Utilities | PLINK 1.9 |

## Pull the image
```bash
docker pull chiomab/prscsx:v1.3
```

## Usage
The image bundles an executable usage helper, `prscsx-help.sh` - a usage guide adapted from the tool's original GitHub repository - set as the default command, so it prints when you run the image with no arguments:
```bash
docker run --rm chiomab/prscsx:v1.3
```
To run PRS-CSx on your own data, mount your input and output directories and call the tool:
```bash
docker run --rm \
  -v /path/ldref:/ref -v /path/sumstats:/in -v "$PWD/out":/out \
  chiomab/prscsx:v1.3 \
  bash -lc 'for c in $(seq 1 22); do \
    python /PRS-CSx/PRScsx.py --ref_dir=/ref --bim_prefix=/ref/target \
      --sst_file=/in/EUR_sumstats.txt,/in/AFR_sumstats.txt \
      --n_gwas=208808,3140 --pop=EUR,AFR --chrom=$c \
      --phi=1e-04 --out_dir=/out --out_name=my_prs --seed=42; done'
```

## Self-check
```bash
docker run --rm chiomab/prscsx:v1.3 goss -g /goss.yaml validate
```

## Citation
If you use this image, please cite the original method: [Improving polygenic prediction in ancestrally diverse populations](https://www.nature.com/articles/s41588-022-01054-7).

## Maintainer
Chioma Oselu - chiomabonyido@gmail.com  ·  Docker Hub: https://hub.docker.com/r/chiomab/prscsx
