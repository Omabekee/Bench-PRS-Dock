# JointPRS

**Image:** `chiomab/jointprs:v1.1`  
**Method:** Multi-population Bayesian model with genetic correlation  
**Authors:** Leqi Xu, Geyu Zhou, Wei Jiang, Haoyu Zhang, Yikai Dong, Leying Guan, Hongyu Zhao  
**GitHub:** https://github.com/LeqiXu/JointPRS  
**Paper:** [JointPRS: a data-adaptive framework for multi-population genetic risk prediction incorporating genetic correlation (Nature Communications, 2025)](https://doi.org/10.1038/s41467-025-59143-0)

## Overview
JointPRS is a multi-population polygenic score model that jointly models GWAS summary statistics and LD reference panels from multiple populations, incorporating genetic correlation.

## Included software

| Component | Version |
|-----------|---------|
| JointPRS | (GitHub main) |
| Python | 3.8 |
| Python packages | numpy, scipy, h5py |
| Utilities | PLINK 2.0 |

## Pull the image
```bash
docker pull chiomab/jointprs:v1.1
```

## Usage
The image bundles an executable usage helper, `jointprs-help.sh` - a usage guide adapted from the tool's original GitHub repository - set as the default command, so it prints when you run the image with no arguments:
```bash
docker run --rm chiomab/jointprs:v1.1
```
To run JointPRS on your own data, mount your input and output directories and call the tool:
```bash
docker run --rm \
  -v /path/sumstats:/in -v /path/ldref:/ref -v "$PWD/out":/out \
  chiomab/jointprs:v1.1 \
  bash -lc 'for c in $(seq 1 22); do \
    python /jointprs/JointPRS.py --ref_dir=/ref --bim_prefix=/ref/target \
      --pop=EUR,AFR --rho_cons=1,1 \
      --sst_file=/in/EUR_sumstat.txt,/in/AFR_sumstat.txt \
      --n_gwas=208808,3140 --chrom=$c --phi=1e-04 \
      --out_dir=/out --out_name=JointPRS_auto_EUR_AFR_11; done'
```

## Self-check
```bash
docker run --rm chiomab/jointprs:v1.1 goss -g /goss.yaml validate
```

## Citation
If you use this image, please cite the original method: [JointPRS: a data-adaptive framework for multi-population genetic risk prediction incorporating genetic correlation (Nature Communications, 2025)](https://doi.org/10.1038/s41467-025-59143-0).

## Maintainer
Chioma Oselu - chiomabonyido@gmail.com  ·  Docker Hub: https://hub.docker.com/r/chiomab/jointprs
