# syntax=docker/dockerfile:1
# CT-SLEB, built to be byte-identical to the reference conda environment.
# This is the v2.0 recipe, the one used for the published benchmark. It replaces an
# earlier v1.0 recipe (rocker/r-ver base, unpinned install_github) which linked a
# different OpenBLAS build and therefore did not reproduce the published output hash.
#
# Everything that affects the numerical result is pinned:
#   base image tag, the 207-package conda lock (incl. libopenblas 0.3.33
#   pthreads_h94d23a6_0), the CTSLEB commit, the plink and plink2 releases,
#   and single-threaded BLAS.
FROM condaforge/miniforge3:24.9.2-0

ARG CTSLEB_COMMIT=4e3784607b7f0eab4d52d00387bc1d95292cce93
ARG PLINK_SHA256=625e1ace0b70337828a409c67f85ac64441b216df0e9617a05325ebd45130806
ARG PLINK2_SHA256=28e45a65689bacf2b6675898abc6fc2eb2a5de19ae21a60ccec0dd37e6b21ce2

# retry settings, the conda solve pulls roughly 2 GB
RUN printf 'remote_max_retries: 20\nremote_backoff_factor: 2\nremote_connect_timeout_secs: 30\nremote_read_timeout_secs: 180\n' > /root/.condarc

# 1) recreate the exact reference environment from the explicit lock, which fixes the
#    BLAS build and every package binary.
COPY ctsleb_conda_lock.txt /tmp/lock.txt
RUN --mount=type=cache,target=/opt/conda/pkgs \
    mamba create -y -p /opt/ctsleb_env --file /tmp/lock.txt
ENV PATH=/opt/ctsleb_env/bin:$PATH

# 2) single-threaded, deterministic BLAS. The reference run sets the same two variables.
ENV OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1

# 3) CTSLEB at a fixed commit. The devtools import is stripped from DESCRIPTION so the
#    package installs without pulling devtools into the runtime environment.
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates time \
 && rm -rf /var/lib/apt/lists/* \
 && git clone https://github.com/andrewhaoyu/CTSLEB.git /tmp/CTSLEB \
 && cd /tmp/CTSLEB && git checkout ${CTSLEB_COMMIT} && sed -i '/devtools/d' DESCRIPTION \
 && R CMD INSTALL --no-test-load . \
 && rm -rf /tmp/CTSLEB

# 4) plink 1.9.0-b.7.6 and plink2 2.0.0-a.6.9. The original build copied these binaries
#    from the reference environment. The pinned releases below are the same builds, and
#    the checksums are verified so the result is identical either way.
RUN wget -qO /tmp/p19.zip https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20241013.zip \
 && unzip -q /tmp/p19.zip plink -d /usr/local/bin/ \
 && echo "${PLINK_SHA256}  /usr/local/bin/plink" | sha256sum -c - \
 && wget -qO /tmp/p2.zip https://s3.amazonaws.com/plink2-assets/alpha6/plink2_linux_x86_64_20250129.zip \
 && unzip -q /tmp/p2.zip plink2 -d /usr/local/bin/ \
 && echo "${PLINK2_SHA256}  /usr/local/bin/plink2" | sha256sum -c - \
 && chmod +x /usr/local/bin/plink /usr/local/bin/plink2 \
 && rm -f /tmp/p19.zip /tmp/p2.zip

WORKDIR /out

COPY --chmod=0755 ctsleb-help.sh /usr/local/bin/ctsleb-help
COPY goss.yaml /goss.yaml
ADD --chmod=0755 https://github.com/goss-org/goss/releases/download/v0.4.9/goss-linux-amd64 /usr/local/bin/goss
COPY run_ctsleb.R /usr/local/bin/run_ctsleb.R
RUN useradd -m -u 1000 appuser
USER appuser
CMD ["ctsleb-help"]
