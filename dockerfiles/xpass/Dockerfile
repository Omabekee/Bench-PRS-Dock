FROM ubuntu:22.04
LABEL maintainer="Chioma <chiomabonyido@gmail.com>"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    build-essential cmake wget unzip git gcc \
    libcurl4-openssl-dev libxml2-dev libfontconfig1-dev libfreetype6-dev \
    libharfbuzz-dev libfribidi-dev libssl-dev libudunits2-dev libgdal-dev \
    libproj-dev libxt-dev libv8-dev libpng-dev libjpeg-dev libtiff-dev \
    libgfortran5 python3 python3-pip r-base sudo curl \
    && apt clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /xpass user
WORKDIR /xpass

# R dependencies (plotting toolchain + XPASS runtime deps)
RUN R -e "install.packages('systemfonts')"
RUN R -e "install.packages('textshaping')"
RUN R -e "install.packages('ragg')"
RUN R -e "install.packages('pkgdown')"
RUN R -e "install.packages('data.table')"
RUN R -e "install.packages('RhpcBLASctl')"
RUN R -e "install.packages('ieugwasr')"

# plink 1.9 (XPASS+ clumping)
RUN apt-get update && apt-get install -y wget unzip \
    && wget https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20241013.zip \
    && unzip plink_linux_x86_64_20241013.zip && mv plink /usr/local/bin/ \
    && rm plink_linux_x86_64_20241013.zip

# XPASS R package from source
RUN R -e "install.packages('devtools', repos='https://cran.rstudio.com/')"
RUN Rscript -e "devtools::install_github('YangLabHKUST/XPASS')"

# XPASS fourier LD-block region files into the package extdata (used by sd_method='LD_block')
RUN mkdir -p /usr/local/lib/R/site-library/XPASS/extdata
COPY AFR_fourier_ls-all.bed /usr/local/lib/R/site-library/XPASS/extdata/
COPY EUR_fourier_ls-all.bed /usr/local/lib/R/site-library/XPASS/extdata/
COPY EAS_fourier_ls-all.bed /usr/local/lib/R/site-library/XPASS/extdata/
RUN chown -R user:user /xpass

# Use OpenBLAS for BLAS/LAPACK (via update-alternatives; no R recompile)
RUN apt-get update && apt-get install -y --no-install-recommends libopenblas0-pthread && \
    update-alternatives --set libblas.so.3-x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 && \
    update-alternatives --set liblapack.so.3-x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/openblas-pthread/liblapack.so.3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --chmod=0755 xpass-help.sh /usr/local/bin/xpass-help
COPY goss.yaml /goss.yaml
ADD --chmod=0755 https://github.com/goss-org/goss/releases/download/v0.4.9/goss-linux-amd64 /usr/local/bin/goss
COPY run_xpass.R /usr/local/bin/run_xpass.R
USER user
CMD ["xpass-help"]
