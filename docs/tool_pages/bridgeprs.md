# BridgePRS - Detailed Documentation (Bench-PRS Dock)
**Image**: chiomab/bridgeprs:v1.5

**Version:** 0.1.7

**Purpose:** Bayesian ridge regression–based PRS method for multi-ancestry prediction

**Authors:** Clive J. Hoggart, Shing Wan Choi,  Judit García-González, Tade Souaiaia, Michael Preuss & Paul F. O’Reilly

**Website:** https://www.bridgeprs.net/

**GitHub Documentation:** https://github.com/clivehoggart/BridgePRS

**Published Paper:** [BridgePRS leverages shared genetic effects across ancestries to increase polygenic risk score portability](https://www.nature.com/articles/s41588-023-01583-9)

**Docker Image Maintainer**: Chioma Onyido (Oselu)
- Email: chiomabonyido@gmail.com
- LinkedIn: [Chioma Onyido](https://www.linkedin.com/in/chioma-onyido/)

**Docker Hub page:** https://hub.docker.com/r/chiomab/bridgeprs

Last updated: 2025-07-12

---
## Overview
BridgePRS implements Bayesian ridge regression within a three-stage framework to construct ancestry-aware PRS using summary and individual-level data.

In **Bench-PRS Dock**, this container provides a fully reproducible environment with all dependencies preinstalled.

---
## Included Software & Versions

| Component | Version | 
|-------|-------------|
| **Main tool** | BridgePRS 0.1.7
| **R / Python** | Python v3+, R v3.6.3
| **Key dependencies** | parallel, glmnet, boot, data.table, doMC, BEDMatrix v2.0.3, optparse and MASS
| **Additional utilities**| plink 1.9

---
## Pull the Image
``` bash
docker pull chiomab/bridgeprs:v1.5
```

---
## Run Example
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


## Citation

Container maintained by Chioma Onyido (Oselu).
If you use this container, please cite both the original method and the Bench-PRS Dock resource.

## Related Resources
Docker Hub page: https://hub.docker.com/r/chiomab/bridgeprs