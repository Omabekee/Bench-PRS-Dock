# XP-BLUP

**Image:** `chiomab/xpblup:v1.1`  
**Method:** Two-component linear mixed model (BLUP)  
**Authors:** Marc Coram, Huaying Fang, Sophie Candille, Themistocles Assimes, Hua Tang  
**GitHub:** https://github.com/tanglab/XP-BLUP  
**Paper:** [Leveraging Multi-ethnic Evidence for Risk Assessment of Quantitative Traits in Minority Populations](https://doi.org/10.1016/j.ajhg.2017.06.015)

## Overview
XP-BLUP improves complex-trait prediction in minority populations by combining trans-ethnic and ethnic-specific information in a two-component linear mixed model.

## Included software

| Component | Version |
|-----------|---------|
| XP-BLUP | (GitHub master) |
| GCTA | 1.94.4 |
| Utilities | PLINK 1.9 |

## Pull the image
```bash
docker pull chiomab/xpblup:v1.1
```

## Usage
The image bundles an executable usage helper, `xpblup-help.sh` - a usage guide adapted from the tool's original GitHub repository - set as the default command, so it prints when you run the image with no arguments:
```bash
docker run --rm chiomab/xpblup:v1.1
```
To run XP-BLUP on your own data, mount your input and output directories and call the tool:
```bash
docker run --rm \
  -v /path/data:/data -v "$PWD/out":/work \
  chiomab/xpblup:v1.1 \
  ./xpblup.sh --plink=/usr/local/bin/plink --gcta=/usr/local/bin/gcta64 \
    --pheno=/data/train.pheno --train=/data/train --test=/data/test \
    --snplist=/data/snps.txt --outdir=/work --outprefix=xpblup
```

## Self-check
```bash
docker run --rm chiomab/xpblup:v1.1 goss -g /goss.yaml validate
```

## Citation
If you use this image, please cite the original method: [Leveraging Multi-ethnic Evidence for Risk Assessment of Quantitative Traits in Minority Populations](https://doi.org/10.1016/j.ajhg.2017.06.015).
  
Upstream contact: huatang@stanford.edu / hyfang@stanford.edu.

## Maintainer
Chioma Oselu - chiomabonyido@gmail.com  ·  Docker Hub: https://hub.docker.com/r/chiomab/xpblup
