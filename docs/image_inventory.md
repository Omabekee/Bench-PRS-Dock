# Image inventory

Each tool ships as a self-documenting Docker image on Docker Hub (`chiomab/<tool>`). A bare
`docker run <image>` prints usage; `docker run <image> goss -g /goss.yaml validate` self-checks the
internal dependencies. The `RepoDigest` is the immutable content reference - `docker pull <repo>@<digest>`
(or `apptainer pull docker://<repo>@<digest>`) always returns exactly this image.

| Tool | Image | Base | Language | Method class | Key dependencies |
|------|-------|------|----------|--------------|------------------|
| PRSice-2 | `chiomab/prsice:v1.1` | rocker/r-ver:4.1.2 | C++ / R | Clumping + p-value thresholding (C+T) | data.table, ggplot2, PLINK 1.9 |
| PRS-CSx | `chiomab/prscsx:v1.3` | python:3.8-slim | Python | Bayesian continuous shrinkage (multi-ancestry) | numpy, scipy, h5py, PLINK 1.9 |
| SDPRX | `chiomab/sdprx:v1.1` | continuumio/miniconda3 | Python | Nonparametric Bayesian mixture | numpy, scipy, pandas, joblib, PLINK 1.9 |
| TL-PRS | `chiomab/tl-prs:v1.3` | ubuntu:22.04 (R 4.1.2) | R | Transfer learning | TLPRS, lassosum, data.table, PLINK 1.9 |
| XPASS / XPASS+ | `chiomab/xpass:v1.4` | ubuntu:22.04 (R 4.1.2) | R | Bayesian hierarchical (shared + population-specific effects) | XPASS, data.table, RhpcBLASctl, ieugwasr, PLINK 1.9 |
| BridgePRS | `chiomab/bridgeprs:v1.6` | ubuntu:22.04 (R 4.1.2) | R / bash | Bayesian ridge regression (three-stage) | BEDMatrix, glmnet, MASS, data.table, PLINK 1.9 |
| JointPRS | `chiomab/jointprs:v1.1` | python:3.8-slim | Python | Multi-population Bayesian with genetic correlation | numpy, scipy, h5py, PLINK 2.0 |
| CT-SLEB | `chiomab/ctsleb:v2.1` | rocker/r-ver:4.1.2 | R | Clump-threshold + empirical Bayes + super-learning | CTSLEB, SuperLearner, ranger, glmnet, PLINK 1.9/2.0 |
| XP-BLUP | `chiomab/xpblup:v1.1` | ubuntu:22.04 | Shell / GCTA | Two-component linear mixed model (BLUP) | GCTA, PLINK 1.9 |

## RepoDigests (pull-by-digest)
Pulling by digest guarantees the exact image used in the benchmark, independent of any later change to the tag. For example:
`docker pull chiomab/prsice@sha256:39ddea2e57d254fb50cc8edf749899c0b07d1dc50f8a2b152e55bbe5d9aa0fd7`

| Image | RepoDigest |
|-------|------------|
| `chiomab/prsice:v1.1` | `sha256:39ddea2e57d254fb50cc8edf749899c0b07d1dc50f8a2b152e55bbe5d9aa0fd7` |
| `chiomab/prscsx:v1.3` | `sha256:5f72838d93a988b14e072cabb6adc29fa67e7df5e306995dd3af2710dff1c7a4` |
| `chiomab/sdprx:v1.1` | `sha256:f4c535251b8866b9a8e13e21af54a8b4f664d7a98db662b24803f3bfac7b1c2f` |
| `chiomab/tl-prs:v1.3` | `sha256:17be802243897198dda1ba55b5953f7741a84f817d9a5fb96160ba1bafa0679b` |
| `chiomab/xpass:v1.4` | `sha256:644ee5e7d3ead88d33216a5fb9538bfc74612e524eeaf6bc07d460b27bb019fa` |
| `chiomab/bridgeprs:v1.6` | `sha256:ea52bfdb29d9d0918408e1609cb2a4b30c285006eb8a19527a8efa7e2073bf24` |
| `chiomab/jointprs:v1.1` | `sha256:22f9834b17d21c12cb9ae0fc2f5d5f0627600e424328dc7a8fc63cfa8dbfa608` |
| `chiomab/ctsleb:v2.1` | `sha256:46f58fcf467b71ccb7ecc4e8a05f185db2f47ef33cc33fd67719b6f9e26ff3b0` |
| `chiomab/xpblup:v1.1` | `sha256:cde5d43c69b28a1e14e1c2a6cfe84ceae17398c7f34e421f19bf36d0343626b4` |
