# Benchmark results - Docker vs. native

Each tool was run both **natively** and from its **Docker image** on the same prostate-cancer test
data (African-ancestry target, European base), measuring:

- **Setup** - time to install the tool (native) or pull the image (Docker).
- **Execution** - wall-clock time and peak memory to run the tool.
- **Consistency** - whether the native and Docker outputs agree.

Peak memory is the peak resident set size (RSS) measured with GNU `/usr/bin/time -v` (Maximum resident
set size) - the same instrument on both sides. Each measurement is `n = 3` replicates (mean ± SD).
Execution is genome-wide (chromosomes 1-22); the MCMC tools (PRS-CSx, SDPRX, JointPRS) use identical
reduced-iteration settings in both modes, so the Docker/native ratio and peak memory remain comparable.

## Setup and execution (mean ± SD, n = 3)

| Tool | Setup native (s) | Setup Docker (s) | Exec native (s) | Exec Docker (s) | Peak RAM native / Docker (MiB) |
|------|------------------|------------------|-----------------|-----------------|-------------------------------|
| PRSice-2 | 495.9 ± 52.1 | 23.3 ± 6.3 | 8.2 ± 1.1 | 14.4 ± 1.4 | 191 / 186 |
| PRS-CSx | 129.7 ± 22.4 | 78.9 ± 54.4 | 6096.9 ± 1115.5 | 4930.2 ± 579.4 | 736 / 737 |
| SDPRX | 150.4 ± 7.2 | 24.1 ± 18.6 | 4279.0 ± 361.2 | 4375.1 ± 47.2 | 1537 / 1534 |
| TL-PRS | 675.0 ± 40.8 | 144.0 ± 10.7 | 606.4 ± 72.9 | 429.6 ± 133.0 | 1001 / 988 |
| XPASS | 720.5 ± 82.2 | 178.7 ± 5.3 | 226.7 ± 38.1 | 145.8 ± 18.8 | 9855 / 9734 |
| XPASS+ | 720.5 ± 82.2 | 178.7 ± 5.3 | 180.2 ± 29.2 | 145.6 ± 8.4 | 9727 / 8659 |
| BridgePRS | 495.9 ± 138.8 | 172.7 ± 31.1 | 4259.4 ± 70.6 | 4837.8 ± 1129.0 | 3323 / 3311 |
| JointPRS | 769.5 ± 193.1 | 58.0 ± 6.7 | 4958.5 ± 460.8 | 5428.1 ± 548.6 | 735 / 734 |
| CT-SLEB | 502.8 ± 59.8 | 76.9 ± 9.1 | 3073.9 ± 567.1 | 3299.6 ± 644.3 | 3117 / 3157 |
| XP-BLUP | 59.7 ± 3.9 | 24.1 ± 7.4 | 209.2 ± 2.5 | 210.3 ± 8.2 | 2666 / 2665 |

XPASS+ shares the XPASS environment, so its setup is identical to XPASS. Setup timing reflects two
different operations (native = compile/install, Docker = image pull) and is sensitive to the host and
network; execution time and peak memory are the reproducible, compute-bound measures.

## Docker-vs-native fold (native mean ÷ Docker mean)

Values > 1 mean Docker was faster; < 1 mean Docker was slower.

| Tool | Setup fold | Exec fold |
|------|-----------|-----------|
| PRSice-2 | 21.28× | 0.57× |
| PRS-CSx | 1.64× | 1.24× |
| SDPRX | 6.25× | 0.98× |
| TL-PRS | 4.69× | 1.41× |
| XPASS | 4.03× | 1.55× |
| XPASS+ | 4.03× | 1.24× |
| BridgePRS | 2.87× | 0.88× |
| JointPRS | 13.28× | 0.91× |
| CT-SLEB | 6.54× | 0.93× |
| XP-BLUP | 2.48× | 0.99× |

Docker setup is faster for every tool (it pulls a ready image instead of compiling/installing).
Execution is near parity across tools (0.57-1.55×).

## Output consistency (native vs. Docker)

| Tool | Verdict | Pearson r | Spearman rho | Top 10% overlap | Notes |
|------|---------|-----------|--------------|-----------------|-------|
| PRSice-2 | Identical | 1.0 | 1.0 | 1.00 | deterministic (byte-identical output) |
| PRS-CSx | Identical | 1.0 | 1.0 | 1.00 | seeded MCMC |
| SDPRX | Differ | 0.913186 | 0.904090 | 0.72 | unseeded MCMC (run-to-run noise, not a container effect) |
| TL-PRS | Identical | 1.0 | 1.0 | 1.00 | deterministic |
| XPASS | Identical | 1.0 | 1.0 | 1.00 | deterministic |
| XPASS+ | Identical | 1.0 | 1.0 | 1.00 | deterministic |
| BridgePRS | Differ | 1.000000 | 1.0 | 1.00 | stochastic; agreement to ~7 decimals, no change in rank |
| JointPRS | Identical | 1.0 | 1.0 | 1.00 | seeded MCMC |
| CT-SLEB | Identical | 1.0 | 1.0 | 1.00 | seeded ensemble |
| XP-BLUP | Identical | 1.0 | 1.0 | 1.00 | deterministic |

All tools are compared on the per-individual polygenic score, so the numbers are directly
comparable across tools. PRS-CSx, SDPRX and JointPRS emit per-SNP posterior effects rather than
individual scores, so their scores were generated from those weights with `plink --score`, using the
same plink build on both sides.

For deterministic tools the native and Docker outputs are byte-identical (SHA256). Tools that are
inherently stochastic are compared with Pearson and Spearman correlation and with the overlap of the
top 10 percent of individuals by score. SDPRX has no random seed, so its sub-1.0 values reflect MCMC
run-to-run noise rather than a Docker-vs-native difference: two native runs of SDPRX disagree by the
same amount.

## Figures

See [`../figures/`](../figures): setup and execution time comparisons (linear and log), and the
setup/execution efficiency-ratio bar charts. Regenerate them with
[`../analysis/plot_obj1_benchmarks.py`](../analysis/plot_obj1_benchmarks.py); regenerate the CSVs in
[`../results/`](../results) with [`../analysis/prep_master.py`](../analysis/prep_master.py).
