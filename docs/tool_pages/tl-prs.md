# TL-PRS

**Image:** `chiomab/tl-prs:v1.3`  
**Method:** Transfer learning  
**Authors:** Zhangchen Zhao, Lars G. Fritsche, Jennifer A. Smith, Bhramar Mukherjee, Seunggeun Lee  
**GitHub:** https://github.com/ZhangchenZhao/TLPRS  
**Paper:** [The Construction of Multi-ethnic Polygenic Risk Score using Transfer Learning (medRxiv, 2022)](https://www.medrxiv.org/content/10.1101/2022.03.29.22273213)

## Overview
TL-PRS uses transfer learning to adapt a source-population polygenic score to a target population, improving multi-ethnic polygenic prediction.

## Included software

| Component | Version |
|-----------|---------|
| TLPRS | 1.0.0 |
| R | 4.1.2 |
| R packages | lassosum, data.table |
| Utilities | PLINK 1.9 |

## Pull the image
```bash
docker pull chiomab/tl-prs:v1.3
```

## Usage
The image bundles an executable usage helper, `tl-prs-help.sh` - a usage guide adapted from the tool's original GitHub repository - set as the default command, so it prints when you run the image with no arguments:
```bash
docker run --rm chiomab/tl-prs:v1.3
```
To run TL-PRS on your own data, mount your input and output directories and call the tool:
```bash
docker run --rm \
  -v /path/data:/data -v "$PWD/out":/work \
  chiomab/tl-prs:v1.3 \
  Rscript /usr/local/bin/run_tlprs.R \
    /data/pheno.ped Covar Y binary /data/train /data/test \
    /data/EUR_base_ss.txt /data/AFR_target_ss.txt EUR \
    /usr/local/bin/plink /data/AFR_geno /data/AFR_pheno.txt /work/tlprs
```

## Self-check
```bash
docker run --rm chiomab/tl-prs:v1.3 goss -g /goss.yaml validate
```

## Citation
If you use this image, please cite the original method: [The Construction of Multi-ethnic Polygenic Risk Score using Transfer Learning (medRxiv, 2022)](https://www.medrxiv.org/content/10.1101/2022.03.29.22273213).
  
Upstream contact: Zhangchen Zhao <zczhao@umich.edu>.

## Maintainer
Chioma Oselu - chiomabonyido@gmail.com  ·  Docker Hub: https://hub.docker.com/r/chiomab/tl-prs
