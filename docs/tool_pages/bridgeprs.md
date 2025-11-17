# BridgePRS - Detailed Documentation (Bench-PRS Dock)
**Image**: chiomab/bridgeprs:v1.5

**Version:** 1.5

**Purpose:** Bayesian ridge regression–based PRS method for multi-ancestry prediction

**Maintainer**: Chioma Onyido

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

**More details in BridgePRS official documentation - GitHub Link: [Hoggart et al. (2024)](https://github.com/clivehoggart/BridgePRS)**


## Citation

BridgePRS paper: Hoggart et al., 2024.

Container maintained by Chioma Onyido (2025).
If you use this container, please cite both the original method and the Bench-PRS Dock resource.

## Related Resources

Docker Hub page: https://hub.docker.com/u/chiomab