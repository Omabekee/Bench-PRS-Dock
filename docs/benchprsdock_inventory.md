## Bench-PRS Dock - Technical Inventory

This technical inventory provides detailed metadata for each container in the Bench-PRS Dock suite. Unlike the main [`Bench-PRS Tool Suite`](../README.md#bench-prs-tool-suite) table, which lists only the tool name, tag, size and citation, this section documents the technical internals of each image to support transparency, debugging and reproducibility.

### Column Descriptions

**Tool** - Name of the PRS tool or package.

**Docker Image / Tag** - Exact image and version used for execution.

**SHA Digest** - Content-addressed hash that uniquely identifies the image.

**Base Image** - The foundational operating system or environment the container is built on.

**Language** - Primary programming language used by the tool.

**Statistical Method/ Class** - The statistical or modeling framework behind the tool.

**Key Dependencies / Resources** - Major libraries or software bundled inside the container.


| Tool        | Docker Image / Tag              | SHA Digest     | Base Image        | Language | Statistical Method/ Class                                 | Key Dependencies / Resources               |
|-------------|----------------------------------|-----------------|-------------------|----------|------------------------------------------------|---------------------------------------------|
| PRS-CSx     | chiomab/prscsx:v1.2              | sha256:dc1be542e5d33a06d680d4f0ff78f5f0cfdb43f7cf258463041ba91c14984a34    | python:3.8-slim      | Python   | Bayesian continuous shrinkage | scipy, h5py, PLINK     |
| BridgePRS   | chiomab/bridgeprs:v1.5           | sha256:60fcf6972ce58b97870962ab323941db32cb7f55134b4d1237e622da2a88e4b6    | ubuntu:22.04     | R, Python        | Bayesian ridge regression (three-stage)        | BEDMatrix, glmnet, boot, data.table, doMC, glmnet, MASS, optparse, parallel, R.utils, PLINK                    |
| SDPRX       | chiomab/sdprx:v1.0               | sha256:b298b24af6ad23b6a3c3631ad44be37b415ca0e13a91cd209a8898174dbfcb31    | continuumio/miniconda3    | Python   | Nonparametric Bayesian mixture model           | numpy, scipy, pandas, joblib                         |
| XPASS / XPASS+ | chiomab/xpass:v1.2             | sha256:e4f3ce2270b6a867f22134f33c01609d686fa556712cc6e742bd1b762530da95    | rocker/r-base     | R        | Bayesian hierarchical (shared + ancestry-specific) | ieugwasr, data.table, devtools, RhpcBLASct1, Fourier LD files  |
| XP-BLUP     | chiomab/xpblup:v1.0              | sha256:62d8252f75cc653405c444282ffb225393239a365a1a0ef923ea8b9937022441    | ubuntu:22.04      | Shell/GCTA | Two-component linear mixed model (BLUP)     | PLINK, GCTA                                  |
| GAUDI       | chiomab/gaudi-prs:v1.0               | sha256:7c904894fb4db18532fd9bfbc532f5ef0855718f8037189983dcde646719f084    | ubuntu:22.04 | R, Python        | Penalized regression with ancestry-specific effects | Matrix, optparse, data.table, tidyverse, igraph, splitTools, caret, qlcMatrix |
| PolyFun     | chiomab/polyfun:v1.3             | sha256:323b6351333428b55641d8432bd5d1b7baed2d1a3ca765078d6ffc730c80efac    | continuumio/miniconda3    | Python, R   | Functional-prior Bayesian fine-mapping        |   | devtools, ggplot2, crayon, ckmeans.1d.dp, susier, reshape, matrixstats, remotes, mixsqp, PLINK
| snpnet      | chiomab/snpnet:v1.1              | sha256:54f45d592eb355adc872fa1985d8f3de1a54f9c2e93c698e5706184f19c1c2d5    | ubuntu:22.04     | R        | Lasso GLM  | devtools, myglmnet, snpnet, zstd, PLINK   |
| TL-PRS      | chiomab/tl-prs:v1.2              | sha256:190ff3f28e52d9234bdeeecbac19056733c51030da5a0abf108cca0887828e58    | ubuntu:22.04      | Python, R   | Transfer-learning | data.table, devtools, lassosum  |
