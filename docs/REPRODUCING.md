# Reproducing the benchmark

## Pull the images

Images are not stored in this repository. Pull them from Docker Hub:

```bash
docker pull chiomab/prsice:v1.0      docker pull chiomab/bridgeprs:v1.5
docker pull chiomab/prscsx:v1.2      docker pull chiomab/jointprs:v1.0
docker pull chiomab/sdprx:v1.0       docker pull chiomab/ctsleb:v2.0
docker pull chiomab/tl-prs:v1.2      docker pull chiomab/xpblup:v1.0
docker pull chiomab/xpass:v1.3       # XPASS+ shares this image
```

On an HPC the same images run under Apptainer:

```bash
apptainer pull docker://chiomab/prsice:v1.0
```

To pin an exact build rather than a tag, pull by digest. The digests are in
`provenance/tool_provenance.csv`:

```bash
docker pull chiomab/xpass@sha256:b845cb812678926390105639be9528caf2fbc38657887c8abe6f92db3a479e43
```

## Sources

| Paper item | Produced from | Script |
|---|---|---|
| Table 1, tools packaged | `docs/tool_pages/` | - |
| Table 2, build specifications | `provenance/tool_provenance.csv`, `docs/image_inventory.md` | - |
| Table 3, setup wall-time | `benchmark/local/results/benchmark_summary.csv` (setup rows), `benchmark/hpc/results/benchmark_summary.csv` | `benchmark/analysis/prep_master.py` |
| Table 4, execution wall-time and peak memory | the same two files (exec rows) | `benchmark/analysis/prep_master.py` |
| Table S2, data sources | not in this repository, see the accessions in the paper | - |
| Table S3, build provenance | `provenance/tool_provenance.csv` and the lockfiles beside it | - |
| Table S4, score file digests | `benchmark/digests/per_individual_score_digests.csv` | - |
| Table S5, consistency metrics | `benchmark/hpc/results/consistency_per_individual.csv`, `consistency_native_vs_docker.csv`, `consistency_three_way.csv` | - |
| Local figures | `benchmark/local/figures/` | `benchmark/analysis/plot_obj1_benchmarks.py` |
| HPC figures | `benchmark/hpc/figures/` | `benchmark/analysis/plot_hpc_benchmarks.py` |

## Running it

```bash
python benchmark/harness/local/obj1_bench.py exec <tool>   # native and Docker
bash   benchmark/harness/hpc/submit_chain.sh               # Apptainer under Slurm
python benchmark/analysis/prep_master.py                   # rebuild the result CSVs
python benchmark/analysis/plot_obj1_benchmarks.py          # rebuild local figures
python benchmark/analysis/plot_hpc_benchmarks.py           # rebuild HPC figures
```

## Per-individual outputs are not shared

The target genotypes are controlled-access dbGaP data (accession phs001391.v1.p1), so the
per-individual polygenic score files cannot be redistributed here. They are excluded by
`.gitignore`.

What is published instead is their SHA-256 digests, in
`benchmark/digests/per_individual_score_digests.csv`, which reveal nothing about any
individual. An authorised user who regenerates the scores with the commands in
`benchmark/harness/` can hash their own output and confirm it matches, which verifies the
consistency results without exposing participant data. `benchmark/DATA_AVAILABILITY.md`
records the exact scoring commands used for the three tools whose scores were derived with
plink.

## Building an image

Each `dockerfiles/<tool>/` folder is a self-contained recipe (the tool installed from its GitHub
source, plus the usage helper, goss self-test, and non-root user):

```bash
cd dockerfiles/prsice && docker build -t chiomab/prsice:v1.1 .
```
