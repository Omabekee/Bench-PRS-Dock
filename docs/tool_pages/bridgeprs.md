# BridgePRS - Bench-PRS Dock Documentation
**Image:** `chiomab/bridgeprs:v1.5`  
**Tool Version:** 0.1.7  
**Method Type:** Bayesian ridge regression–based PRS for multi-ancestry prediction

**Authors:** Clive J. Hoggart, Shing Wan Choi,  Judit García-González, Tade Souaiaia, Michael Preuss & Paul F. O’Reilly

**Website:** https://www.bridgeprs.net/  
**GitHub:** https://github.com/clivehoggart/BridgePRS  
**Published Paper:**  
[BridgePRS leverages shared genetic effects across ancestries to increase polygenic risk score portability](https://www.nature.com/articles/s41588-023-01583-9)  

---

## Maintainer (Bench-PRS Dock)
**Chioma Blessing Onyido (Oselu)**
- Email: chiomabonyido@gmail.com
- LinkedIn: [Chioma Onyido](https://www.linkedin.com/in/chioma-onyido/)
- Docker Hub: https://hub.docker.com/r/chiomab/bridgeprs

Last updated: 2025-07-12

---
## 1. Overview
BridgePRS implements a three-stage Bayesian ridge regression framework to generate ancestry-aware polygenic scores using both GWAS summary statistics and individual-level data.

Within **Bench-PRS Dock**, the container provides:
- Fully reproducible environment  
- Preinstalled dependencies  
- Stable versioning 

---

## 2. Included Software & Versions

| Component | Version | 
|-------|-------------|
| **BridgePRS** | 0.1.7 |
| **R** | 3.6.3 |
| **Python** | 3+ |
| **Key dependencies** | parallel, glmnet, boot, data.table, doMC, BEDMatrix v2.0.3, optparse and MASS |
| **Utilities**| PLINK 1.9 |

---
## 3. Pull the Image
``` bash
docker pull chiomab/bridgeprs:v1.5
```

---

## 4. Example Run
```bash
docker run --rm \
  -v ~/BridgePRS/data:/data \
  -v ~/results:/results \
  chiomab/bridgeprs:v1.5 \
bash -c './bridgePRS pipeline go \
  -o /bridgeprs \
  --config_files /data/afr.config /data/eur.config \
  --phenotype y
```
---

## 5. Citation
If you use this container, please cite both the original method and the Bench-PRS Dock resource.

---

## 6. Related Resources
Docker Hub page: https://hub.docker.com/r/chiomab/bridgeprs