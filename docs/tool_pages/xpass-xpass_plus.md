# SDPRX - Bench-PRS Dock Documentation
**Image:** `chiomab/xpass:v1.2`  
**Tool Version:** Latest  
**Method Type:** Bayesian hierarchical model for multi-ancestry polygenic scoring

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
XPASS and XPASS+ apply a Bayesian hierarchical framework to combine ancestry-specific and shared genetic effects to improve polygenic scoring in diverse populations. They leverage large European GWAS datasets to boost prediction accuracy in under-represented target


Within **Bench-PRS Dock**, the container provides:
- Fully reproducible environment  
- Preinstalled dependencies  
- Stable versioning 

---

## 2. Included Software & Versions



---
## 3. Pull the Image
``` bash
docker pull chiomab/xpblup:v1.0
```

---

## 4. Example Run
```bash
docker run --rm \
  -v ~/XPASS/XPASS_demo:/data \
  -v ~/results:/results \
  chiomab/xpass:v1.2 \
  Rscript /data/run_xpass_bmi_test.R
```
---

## 5. Citation
If you use this container, please cite both the original method and the Bench-PRS Dock resource.

---

## 6. Related Resources
Docker Hub page: https://hub.docker.com/r/chiomab/xpass