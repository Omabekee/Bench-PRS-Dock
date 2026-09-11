# CT-SLEB

**Image:** `chiomab/ctsleb:v2.1`  
**Method:** Clump-threshold + empirical Bayes + super-learning  
**Authors:** Haoyu Zhang, Jianan Zhan, Jin Jin, Jingning Zhang, Wenxuan Lu, Ruzhang Zhao, and colleagues; Nilanjan Chatterjee  
**GitHub:** https://github.com/andrewhaoyu/CTSLEB  
**Paper:** [A new method for multiancestry polygenic prediction improves performance across diverse populations (Nature Genetics, 2023)](https://doi.org/10.1038/s41588-023-01501-z)

## Overview
CT-SLEB generates multi-ancestry polygenic scores in three steps: clumping and thresholding to select SNPs, an empirical-Bayes step to estimate coefficients, and a super-learning model to combine scores across thresholds.

## Included software

| Component | Version |
|-----------|---------|
| CTSLEB | 0.1.0 |
| R | 4.1.2 |
| R packages | SuperLearner, ranger, glmnet, caret, dplyr, data.table, pROC |
| Utilities | PLINK 1.9, PLINK 2.0 |

## Pull the image
```bash
docker pull chiomab/ctsleb:v2.1
```

## Usage
The image bundles an executable usage helper, `ctsleb-help.sh` - a usage guide adapted from the tool's original GitHub repository - set as the default command, so it prints when you run the image with no arguments:
```bash
docker run --rm chiomab/ctsleb:v2.1
```
To run CT-SLEB on your own data, mount your input and output directories and call the tool:
```bash
docker run --rm \
  -v /path/sumstats:/in -v /path/geno:/geno -v /path/ldref:/ref -v "$PWD/out":/work \
  chiomab/ctsleb:v2.1 \
  Rscript /usr/local/bin/run_ctsleb.R \
    /in/EUR_sumstats.txt /in/AFR_sumstats.txt \
    /geno/AFR_tune /geno/AFR_valid /ref/EUR_chr /ref/AFR_chr \
    /usr/local/bin/plink /usr/local/bin/plink2 /work 42
```

## Self-check
```bash
docker run --rm chiomab/ctsleb:v2.1 goss -g /goss.yaml validate
```

## Citation
If you use this image, please cite the original method: [A new method for multiancestry polygenic prediction improves performance across diverse populations (Nature Genetics, 2023)](https://doi.org/10.1038/s41588-023-01501-z).
  
Upstream contact: Haoyu Zhang <haoyu.zhang2@nih.gov>.

## Maintainer
Chioma Oselu - chiomabonyido@gmail.com  ·  Docker Hub: https://hub.docker.com/r/chiomab/ctsleb
