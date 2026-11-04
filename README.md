# Bench-PRS Dock: A Containerised Collection of Multi-Ancestry Polygenic Risk Score Tools for Reproducible Deployment and Benchmarking

Reproducible Docker images for ten multi-ancestry polygenic risk score (PRS) tools, and a benchmark
comparing each tool run across native, Docker and Apptainer execution (setup time, execution time,
peak memory and output consistency).

Every image is **self-documenting**: a bare `docker run <image>` prints the tool's usage - and
**self-verifying**: `docker run <image> goss -g /goss.yaml validate` checks its internal dependencies.
All images are on Docker Hub under [`chiomab`](https://hub.docker.com/u/chiomab).

![Bench-PRS Dock images](docs/benchprs_dock_fig_1.png)

## How it works

```mermaid
flowchart TD
    src[("Tool sources<br/>10 multi-ancestry PRS tools")]
    data[("Prostate cancer test data<br/>African target · European base")]

    subgraph build["Image build · dockerfiles/&lt;tool&gt;/"]
        df["Dockerfile<br/>pinned base image + tool release"]
        helper["Usage helper<br/>self-documenting image"]
        goss["goss spec<br/>self-verifying dependencies"]
    end

    hub[("Docker Hub<br/>chiomab/&lt;tool&gt;:vX.Y")]

    subgraph prov["Build provenance · provenance/"]
        lock["Dependency lockfiles<br/>conda · pip · R · system"]
        sha["Image SHA-256, seeds<br/>and thread settings"]
    end

    subgraph bench["Benchmark · benchmark/harness/"]
        native["Native install<br/>obj1_bench.py"]
        docker["Docker run<br/>obj1_bench.py"]
        hpc["Apptainer on HPC<br/>run_hpc.py + Slurm"]
    end

    measure["Measures<br/>setup and execution time<br/>peak memory<br/>output consistency"]

    analysis["benchmark/analysis/<br/>tables and figures"]
    results(["docs/RESULTS.md<br/>and benchmark figures"])

    src --> df --> helper --> goss --> hub
    df --> lock
    hub --> sha
    hub --> docker & hpc
    src --> native
    data --> bench
    bench --> measure
    measure --> analysis --> results

    classDef dataset fill:#E5E7EB,stroke:#333,color:#000;
    classDef buildc fill:#BFD7ED,stroke:#333,color:#000;
    classDef reg fill:#D9C8F0,stroke:#333,color:#000;
    classDef provc fill:#FDE68A,stroke:#333,color:#000;
    classDef benchc fill:#A5DFCD,stroke:#333,color:#000;
    classDef meas fill:#F7B267,stroke:#333,color:#000;
    classDef output fill:#EF767A,stroke:#333,color:#000,font-weight:bold;
    class src,data dataset;
    class df,helper,goss buildc;
    class hub reg;
    class lock,sha provc;
    class native,docker,hpc benchc;
    class measure,analysis meas;
    class results output;
    style build fill:#F8FAFC,stroke:#9CA3AF
    style prov fill:#F8FAFC,stroke:#9CA3AF
    style bench fill:#F8FAFC,stroke:#9CA3AF
```

## Tools

| Tool | Image | Method | Page |
|------|-------|--------|------|
| PRSice-2 | `chiomab/prsice:v1.1` | Clumping + p-value thresholding | [prsice](docs/tool_pages/prsice.md) |
| PRS-CSx | `chiomab/prscsx:v1.3` | Bayesian continuous shrinkage | [prscsx](docs/tool_pages/prscsx.md) |
| SDPRX | `chiomab/sdprx:v1.1` | Nonparametric Bayesian mixture | [sdprx](docs/tool_pages/sdprx.md) |
| TL-PRS | `chiomab/tl-prs:v1.3` | Transfer learning | [tl-prs](docs/tool_pages/tl-prs.md) |
| XPASS / XPASS+ | `chiomab/xpass:v1.4` | Bayesian hierarchical | [xpass](docs/tool_pages/xpass-xpass_plus.md) |
| BridgePRS | `chiomab/bridgeprs:v1.6` | Bayesian ridge regression | [bridgeprs](docs/tool_pages/bridgeprs.md) |
| JointPRS | `chiomab/jointprs:v1.1` | Multi-population Bayesian | [jointprs](docs/tool_pages/jointprs.md) |
| CT-SLEB | `chiomab/ctsleb:v2.1` | Clump-threshold + empirical Bayes + super-learning | [ctsleb](docs/tool_pages/ctsleb.md) |
| XP-BLUP | `chiomab/xpblup:v1.1` | Two-component linear mixed model | [xpblup](docs/tool_pages/xpblup.md) |

Full details (base image, language, dependencies, digests): [`docs/image_inventory.md`](docs/image_inventory.md).

## Quick start

```bash
# pull a tool image
docker pull chiomab/prsice:v1.1

# print its usage
docker run --rm chiomab/prsice:v1.1

# check its internal dependencies
docker run --rm chiomab/prsice:v1.1 goss -g /goss.yaml validate
```

The same images work with Apptainer/Singularity on HPC:

```bash
apptainer pull docker://chiomab/prsice:v1.1   # builds prsice_v1.1.sif
apptainer run prsice_v1.1.sif                 # prints usage
```

## Benchmark results

Across all ten tools, Docker setup is faster than native install for every tool (it pulls a ready
image), and execution time and peak memory are near parity between the two modes. Deterministic tools
produce byte-identical native and Docker output. See [`docs/RESULTS.md`](docs/RESULTS.md) for the full
tables and [`benchmark/local/figures/`](benchmark/local/figures) for the plots.

The same ten tools were also run on an HPC under Apptainer, on the same dataset, to test whether the
images carry across machines and container runtimes. Those results are in [`benchmark/hpc/`](benchmark/hpc). Consistency
is assessed on the per-individual polygenic score for every tool, so the tools are directly
comparable.

## Build provenance

[`provenance/`](provenance) records, for each image: the base image and tag, the tool source commit or
release, the image SHA-256, the thread settings and random seeds used, and the full dependency
lockfile exported from inside the image itself (conda, pip, R packages and system packages as
applicable). The summary table is
[`provenance/tool_provenance.csv`](provenance/tool_provenance.csv).

## Reproducing the benchmark

Pulling the images, the source of each table and figure, the commands and the data-sharing note are in [`docs/REPRODUCING.md`](docs/REPRODUCING.md).

## Repository structure

```
dockerfiles/<tool>/      Dockerfile + usage helper + goss spec (+ runner, lockfile)
provenance/              dependency lockfiles exported from each image + tool_provenance.csv
docs/
  RESULTS.md             benchmark tables
  image_inventory.md     image, base, language, method, dependencies, digests
  tool_pages/            one page per tool (method, authors, paper, usage)
benchmark/
  harness/local/         native and Docker runner (obj1_bench.py, registry.json)
  harness/hpc/           Apptainer runner and Slurm submission scripts
  harness/shared/        R runners used by both environments
  analysis/              scripts that regenerate the result CSVs and figures
  digests/               SHA-256 digests of the per-individual score files
  local/results/         native and Docker CSVs
  local/figures/         native and Docker figures
  hpc/results/           Apptainer CSVs
  hpc/figures/           Apptainer figures
  hpc/notes/             note on BLAS kernel selection across CPUs
```

## Citation

If you use these images or results, please cite this repository (see [`CITATION.cff`](CITATION.cff))
and the original tool (each tool page links its paper).

## Maintainer

Chioma Oselu - chiomabonyido@gmail.com · Docker Hub: [chiomab](https://hub.docker.com/u/chiomab)
