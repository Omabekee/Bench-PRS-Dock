# SDPRX - Bench-PRS Dock Documentation
**Image:** `chiomab/xpblup:v1.0`  
**Tool Version:** Latest  
**Method Type:** Two-component linear mixed model for cross-population polygenic prediction

**Authors:** Coram M., Fang H., Candille S., Assimes T., & Tang, H.
 
**GitHub:** https://github.com/tanglab/XP-BLUP  
**Published Paper:**  
[Leveraging Multi-ethnic Evidence for Risk Assessment of Quantitative Traits in Minority Populations](https://doi.org/10.1016/j.ajhg.2017.06.015)  

---

## Maintainer (Bench-PRS Dock)
**Chioma Blessing Onyido (Oselu)**
- Email: chiomabonyido@gmail.com
- LinkedIn: [Chioma Onyido](https://www.linkedin.com/in/chioma-onyido/)
- Docker Hub: https://hub.docker.com/r/chiomab/xpblup

Last updated: 2025-07-12

---
## 1. Overview
XP-BLUP is a polygenic prediction method that uses a two-component linear mixed model to combine trans-ethnic and ancestry-specific genetic information. XP-BLUP uses 'BLUP' to improve prediction accuracy, especially in minority ancestry populations.


Within **Bench-PRS Dock**, the container provides:
- Fully reproducible environment  
- Preinstalled dependencies  
- Stable versioning 

---

## 2. Included Software & Versions

| Component | Version | 
|-------|-------------|
| **XP-BLUP** | Latest |
| **GCTA** | v1.25.3 |
| **Utilities**| PLINK 1.9 |

---
## 3. Pull the Image
``` bash
docker pull chiomab/xpblup:v1.0
```

---

## 4. Example Run
```bash
docker run --rm \
  -v ~/data:/data \
  -v ~/results:/results \
  chiomab/xpblup:v1.0 \
bash -c '/xpblup/xpblup.sh \
  --train=/data/trainN4k \
  --test=/data/testN2k \
  --snplist=/data/metaExtract.txt \
  --outdir=/results/xpblup \
  --outprefix=xpblup'
```
---

## 5. Citation
If you use this container, please cite both the original method and the Bench-PRS Dock resource.

---

## 6. Related Resources
Docker Hub page: https://hub.docker.com/r/chiomab/xpblup