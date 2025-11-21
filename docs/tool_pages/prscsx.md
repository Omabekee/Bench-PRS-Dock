# PRS-CSx - Bench-PRS Dock Documentation
**Image:** `chiomab/prscsx:v1.2`  
**Tool Version:** 1.1.0  
**Method Type:** Bayesian shrinkage model for multi-ancestry polygenic scoring

**Authors:** Ruan, Y., Lin, Y. F., Feng, Y. A., Chen, C. Y., Lam, M., Guo, Z., Stanley Global Asia Initiatives, He, L., Sawa, A., Martin, A. R., Qin, S., Huang, H., & Ge, T.
 
**GitHub:** https://github.com/getian107/PRScsx  
**Published Paper:**  
[Improving Polygenic Prediction in Ancestrally Diverse Populations](https://www.nature.com/articles/s41588-022-01054-7)  

---

## Maintainer (Bench-PRS Dock)
**Chioma Blessing Onyido (Oselu)**
- Email: chiomabonyido@gmail.com
- LinkedIn: [Chioma Onyido](https://www.linkedin.com/in/chioma-onyido/)
- Docker Hub: https://hub.docker.com/r/chiomab/prscsx

Last updated: 2025-07-12

---
## 1. Overview
PRS-CSx is an extension of PRS-CS that models multi-ancestry GWAS data using a Bayesian shrinkage approach to generate more transferable polygenic scores across populations.


Within **Bench-PRS Dock**, the container provides:
- Fully reproducible environment  
- Preinstalled dependencies  
- Stable versioning 

---

## 2. Included Software & Versions

| Component | Version | 
|-------|-------------|
| **PRS-CSx** | 1.1.0 |
| **Python** | 3+ |
| **Python packages** | scipy, h5py |
| **Utilities**| PLINK 1.9 |

---
## 3. Pull the Image
``` bash
docker pull chiomab/prscsx:v1.2
```

---

## 4. Example Run
```bash
docker run --rm \
  -v /ld_ref:/ld_ref \
  -v $(pwd)/test_data:/test_data \
  -v $(pwd)/results:/results \
  chiomab/prscsx:v1.2 \
  python PRScsx.py \
  --ref_dir=/ld_ref \
  --bim_prefix=test_data/test \
  --sst_file=test_data/EUR_sumstats.txt,test_data/EAS_sumstats.txt  \
  --n_gwas=200000,100000 \
  --pop=EUR,EAS \
  --chrom=22 \
  --phi=1e-2 \
  --out_dir=/results/prscsx \
  --out_name=test \
  --seed=1234
```
---

## 5. Citation
If you use this container, please cite both the original method and the Bench-PRS Dock resource.

---

## 6. Related Resources
Docker Hub page: https://hub.docker.com/r/chiomab/prscsx 