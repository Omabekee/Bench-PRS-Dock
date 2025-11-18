# Bench-PRS Dock

Bench-PRS Dock is a curated collection of ten Dockerized Polygenic Risk Score (PRS) tools built to make genetic risk prediction analyses reproducible, portable, and easy to benchmark across populations. Each container is versioned, metadata-tracked, and verified for runtime consistency.

---

## Quick Start
Pull and run any tool (example PRS-CSx):

```bash
docker pull chiomab/prscsx:v1.2
docker run --rm \
    -v ld_ref:/ld_ref \
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
    --out_dir=prscsx_results/ \
    --out_name=test \
    --seed=1234
```
See all tool pages in [`docs/tool_pages/`](docs/tool_pages/)

---

## Suite Contents
Full inventory: [`manifest/prsdock_inventory.csv`](https://www.notion.so/docs/reproducibility_manifest.md)

### Bench-PRS Tool Suite
---
| Tools | Docker Tags | Image Size | Citation
|-------|-------------|------------|---------|
| **BridgePRS** | chiomab/bridgeprs:v1.5 | 588.9 MB | [Hoggart et al. (2024)](https://www.nature.com/articles/s41588-023-01583-9) |
| **PRSCSx** | chiomab/prscsx:v1.2 | 118.3 MB | [Ruan et al. (2022)](https://www.nature.com/articles/s41588-022-01054-7) |
| **SDPRX** | chiomab/sdprx:v1.0 | 555.8 MB | [Zhou et al. (2023)](https://doi.org/10.1016/j.ajhg.2022.11.007) |
| **XPASS/ XPASS+** | chiomab/xpass:v1.2 | 689.1 | [Cai et al. (2021)](10.1016/j.ajhg.2021.03.002) |
| **XP-BLUP** | chiomab/xpblup:v1.0 | 51.4 MB| [Coram et al. (2017)](https://doi.org/10.1016/j.ajhg.2017.06.015) |
| **GAUDI** | chiomab/gaudi:v1.1 | 577.3 MB| [Sun et al. (2024)](https://www.nature.com/articles/s41467-024-45135-z) |
| **PolyFun** | chiomab/polyfun:v1.1 | 2.6 GB| [Weissbrod et al. (2022)](https://www.nature.com/articles/s41588-022-01036-9) |
| **SNPNET** | chiomab/snpnet:v1.1 | 811.3 MB | [Qian et al. (2020)](https://doi.org/10.1371/journal.pgen.1009141) |
| **TL-PRS** | chiomab/tl-prs:v1.2 | 635.2 MB | [Zhao et al. (2022)](10.1016/j.ajhg.2022.09.010) |


## Repository Structure
```bash
Bench-PRS-Dock/
├─ README.md
├─ CITATION.cff
├─ LICENSE

├─ docs/
│  └─ tool_pages/
│     └─ <tool_name>.md

├─ manifest/
│  ├─ prsdock_inventory.csv
│  └─ verification_log.csv

├─ benchmarking/
│  ├─ scripts/
│  │  ├─ capture_system_info.sh
│  │  ├─ setup/
│  │  │  ├─ measure_time_setup.sh
│  │  │  ├─ run_manual_setup.sh
│  │  │  └─ run_setup_docker.sh
│  │  └─ execution/
│  │     ├─ measure_time_execution.sh
│  │     ├─ run_manual_execution.sh
│  │     └─ run_docker_execution.sh
│  │
│  ├─ results/
│  │  ├─ setup_benchmarks/
│  │  │  ├─ docker/
│  │  │  │  └─ <tool>/
│  │  │  └─ manual/
│  │  │     └─ <tool>/
│  │  │
│  │  └─ execution_benchmarks/
│  │     ├─ docker/
│  │     │  └─ <tool>/
│  │     └─ manual/
│  │        └─ <tool>/
│  │
│  └─ figures/
```

**Description:**
- **Core files:** `README.md`, `LICENSE`
- **Documentation:** `docs/` - Tool-specific pages and workflow notes  
- **Metadata:** `manifest/` - Docker image inventory and verification logs  
- **Benchmarking Scripts:** `benchmarking/scripts/` - All setup, execution and system-capture scripts used for reproducibility testing
   - `setup/` - Setup-time benchmarking scripts
   - `execution/` - Execution-time benchmarking scripts
   - `capture_system_info.sh` - Environment metadata capture
- **Benchmark Results:** `benchmarking/results/` - Organized setup and execution benchmarks for all tools (Docker vs manual)
- **Figures**: `figures/` - Visuals used in README and publications

## Verification
To reproduce the benchmarking results reported in this repository, run the scripts located in `benchmarking/scripts/`


## Cite Us

For citation and attribution information, please refer to [CITATION.cff](./citation.cff).


---


