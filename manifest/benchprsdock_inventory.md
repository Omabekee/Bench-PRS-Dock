## Bench-PRS Dock — Technical Inventory

This technical inventory provides detailed metadata for each container in the Bench-PRS Dock suite. Unlike the main [`Bench-PRS Tool Suite`](../README.md#bench-prs-tool-suite) table, which lists only the tool name, tag, size and citation, this section documents the technical internals of each image to support transparency, debugging and reproducibility.

### Column Descriptions

Tool - Name of the PRS tool or package.

Docker Image / Tag - Exact image and version used for execution.

SHA Digest - Content-addressed hash that uniquely identifies the image; ensures full reproducibility even if tags change.

Base Image - The foundational operating system or environment the container is built on.

Language - Primary programming language used by the tool.

Method Class - The statistical or modeling framework behind the tool.

Key Dependencies / Resources - Major libraries or software bundled inside the container.


| Tool        | Docker Image / Tag              | SHA Digest     | Base Image        | Language | Method Class                                 | Key Dependencies / Resources               |
|-------------|----------------------------------|-----------------|-------------------|----------|------------------------------------------------|---------------------------------------------|
| PRS-CSx     | chiomab/prscsx:v1.1              | sha256:xxxx    | ubuntu:20.04      | Python   | Bayesian continuous shrinkage (multi-ancestry) | numpy, scipy, h5py, LD reference panels     |
| BridgePRS   | chiomab/bridgeprs:v1.5           | sha256:xxxx    | rocker/r-base     | R        | Bayesian ridge regression (three-stage)        | BEDMatrix, glmnet, PLINK                    |
| SDPRX       | chiomab/sdprx:v1.0               | sha256:xxxx    | ubuntu:minimal    | Python   | Nonparametric Bayesian mixture model           | numpy, scipy, joblib                         |
| XPASS / XPASS+ | chiomab/xpass:v1.2             | sha256:xxxx    | rocker/r-base     | R        | Bayesian hierarchical (shared + ancestry-specific) | ieugwasr, data.table, Fourier LD files  |
| XP-BLUP     | chiomab/xpblup:v1.0              | sha256:xxxx    | ubuntu:20.04      | Shell/GCTA | Two-component linear mixed model (BLUP)     | PLINK, GCTA                                  |
| GAUDI       | chiomab/gaudi:v1.1               | sha256:xxxx    | rocker/tidyverse  | R        | Penalized regression w/ ancestry-specific effects | BEDMatrix, glmnet                        |
| PolyFun     | chiomab/polyfun:v1.1             | sha256:xxxx    | ubuntu:minimal    | Python   | Functional-prior Bayesian fine-mapping        | numpy, scipy, pandas, LD scores              |
| snpnet      | chiomab/snpnet:v1.1              | sha256:xxxx    | rocker/r-base     | R        | Lasso / penalized GLM                         | snpnet, glmnet                               |
| TL-PRS      | chiomab/tl-prs:v1.2              | sha256:xxxx    | python:3.10       | Python   | Transfer-learning PRS                         | numpy, scipy, pandas                          |
