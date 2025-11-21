# XPASS/ XPASS+ - Bench-PRS Dock Documentation
**Image:** `chiomab/xpass:v1.2`  
**Tool Version:** Latest  
**Method Type:** Bayesian hierarchical model for multi-ancestry polygenic scoring using GWAS summary statistics

**Authors:** Cai, M., Xiao, J., Zhang, S., Wan, X., Zhao, H., Chen, G., & Yang, C.
 
**GitHub:** https://github.com/YangLabHKUST/XPASS  
**Published Paper:**  
[A unified framework for cross-population trait prediction by leveraging the genetic correlation of polygenic traits](10.1016/j.ajhg.2021.03.002)  

---

## Maintainer (Bench-PRS Dock)
**Chioma Blessing Onyido (Oselu)**
- Email: chiomabonyido@gmail.com
- LinkedIn: [Chioma Onyido](https://www.linkedin.com/in/chioma-onyido/)
- Docker Hub: https://hub.docker.com/r/chiomab/xpass

Last updated: 2025-07-12

---
## 1. Overview
XPASS is a Bayesian hierarchical model that combines ancestry-specific and shared genetic effects using summary statistics to improve polygenic scoring in under-represented populations.

XPASS+ extends XPASS by incorporating population-specific SNP effects into PRS construction. It requires a pre-selected set of population-specific variants, obtained using a P+T procedure (e.g. via the ieugwasr R package).

They both leverage large European GWAS datasets to boost prediction accuracy in under-represented populations.


Within **Bench-PRS Dock**, the container provides:
- Fully reproducible environment  
- Preinstalled dependencies  
- Stable versioning
- Support for running both **XPASS** and **XPASS+** 

---

## 2. Included Software & Versions

| Component | Version | 
|-------|-------------|
| **R** | 4.0+ |
| **R packages** | systemfonts, textshaping, ragg, pkgdown, data.table, RhpcBLASctl, ieugwasr, devtools |
| **Fourier LD files** | AFR, EUR, EAS panels |
| **Utilities**| PLINK 1.9 |

---
## 3. Pull the Image
``` bash
docker pull chiomab/xpass:v1.2
```

---

## 4. Example Run
```bash
docker run --rm \
  -v ~/XPASS_demo:/data \
  -v ~/results:/results \
  chiomab/xpass:v1.2 \
  Rscript /data/run_xpass.R
```
---

## 5. Citation
If you use this container, please cite both the original method and the Bench-PRS Dock resource.

---

## 6. Related Resources

Docker Hub page: https://hub.docker.com/r/chiomab/xpass
