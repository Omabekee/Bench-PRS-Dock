# BridgePRS - Detailed Documentation (TrANCES-PRS Dock)
**Image**: chiomab/bridgeprs:v1.5

**Version:** 1.5

**Purpose:** Bayesian ridge regression–based PRS method for multi-ancestry prediction

**Maintainer**: Chioma Onyido

Last updated: 2025-07-12

---
## Overview
BridgePRS implements Bayesian ridge regression within a three-stage framework to construct ancestry-aware PRS using summary and individual-level data.

In **TrANCES-PRS Dock**, this container provides a fully reproducible environment with all dependencies preinstalled, standardized I/O folders (/data and /out), and versioned metadata for benchmarking.

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
  -v $PWD/data:/data \
  -v $PWD/out:/out \
  chiomab/bridgeprs:v1.5 \
  bash /opt/<tool>/run_<tool>.sh \
  --sumstats /data/example_sumstats.txt \
  --out /out
```

**More details in BridgePRS official documentation - GitHub Link: [Hoggart et al. (2024)](https://github.com/clivehoggart/BridgePRS)**


## Citation

BridgePRS original method: Hoggart et al., 2024.

Container maintained by Chioma Onyido (2025).
If you use this container, please cite both the original method and the TrANCES-PRS Dock resource.

## Related Resources

Docker Hub page: https://hub.docker.com/r/chiomab/<PRSCSx>

Parent repository: TrANCES-PRS Dock on GitHub

Benchmark protocol: `docs/reproducibility_manifest.md`