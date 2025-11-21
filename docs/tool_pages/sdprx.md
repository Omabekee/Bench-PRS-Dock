# SDPRX - Bench-PRS Dock Documentation
**Image:** `chiomab/sdprx:v1.0`  
**Tool Version:** Latest  
**Method Type:** Nonparametric Bayesian model for polygenic scoring across ancestries

**Authors:** Zhou G, Chen T, Zhao H.
 
**GitHub:** https://github.com/eldronzhou/SDPRX  
**Published Paper:**  
[SDPRX: A statistical method for cross-population prediction of complex traits](https://doi.org/10.1016/j.ajhg.2022.11.007)  

---

## Maintainer (Bench-PRS Dock)
**Chioma Blessing Onyido (Oselu)**
- Email: chiomabonyido@gmail.com
- LinkedIn: [Chioma Onyido](https://www.linkedin.com/in/chioma-onyido/)
- Docker Hub: https://hub.docker.com/r/chiomab/sdprx

Last updated: 2025-07-12

---
## 1. Overview
SDPRX uses a nonparametric Bayesian mixture model to capture diverse SNP effect sizes and generate ancestry-aware polygenic scores across different genetic architectures.


Within **Bench-PRS Dock**, the container provides:
- Fully reproducible environment  
- Preinstalled dependencies  
- Stable versioning 

---

## 2. Included Software & Versions

| Component | Version | 
|-------|-------------|
| **SDPRX** | Latest |
| **Python** | 3+ |
| **Python packages** | numpy, scipy, joblib |
| **Utilities**| PLINK 1.9 |

---
## 3. Pull the Image
``` bash
docker pull chiomab/sdprx:v1.0
```

---

## 4. Example Run
```bash
docker run --rm \
  -v /SDPRX/test:/data \
  -v /results:/results \
  chiomab/sdprx:v1.0 \
bash -c 'source /opt/conda/etc/profile.d/conda.sh && conda activate sdprx_env && \
python /sdprx/SDPRX.py \
  --ss1 /data/EUR.txt \
  --ss2 /data/EAS.txt \
  --N1 40000 \
  --N2 40000 \
  --force_shared TRUE \
  --load_ld /data/ \
  --valid /data/test.bim \
  --chr 1 \
  --rho 0.8 \
  --out /results/sdprx/res_chr1'
```
---

## 5. Citation
If you use this container, please cite both the original method and the Bench-PRS Dock resource.

---

## 6. Related Resources
Docker Hub page: https://hub.docker.com/r/chiomab/sdprx