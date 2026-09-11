FROM ubuntu:22.04

LABEL maintainer="Chioma <chiomabonyido@gmail.com>"

# Avoid user interaction during build
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt update && \
    apt install -y \
    build-essential \
    cmake \
    wget \
    unzip \
    git \
    gcc \
    libcurl4-openssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libssl-dev \
    libudunits2-dev \
    libgdal-dev \
    libproj-dev \
    libxt-dev \
    libv8-dev \
    libpng-dev \
    libjpeg-dev \
    libtiff-dev \
    libgfortran5 \
    python3 \
    python3-pip \
    r-base \
    sudo \
    curl \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20241013.zip \
    && unzip plink_linux_x86_64_20241013.zip \
    && mv plink /usr/local/bin/ \
    && ln -s /usr/local/bin/plink /usr/local/bin/plink-1.9 \
    && rm plink_linux_x86_64_20241013.zip

# Set working directory
RUN useradd -m -d /TL-PRS user
WORKDIR /TL-PRS

# Install required R packages
RUN R -e "install.packages('data.table')"

# Install devtools
RUN R -e "install.packages('devtools', repos='https://cran.rstudio.com/', dependencies = TRUE)"
RUN R -e "library(devtools)"

# Install lassosum + TL-PRS from GitHub
RUN Rscript -e "devtools::install_github('tshmak/lassosum')"
RUN Rscript -e "devtools::install_github('ZhangchenZhao/TLPRS')"

# Use non-root user for safer runtime (optional but good practice)
RUN chown -R user:user /TL-PRS
USER user

# Default to bash shell

COPY --chmod=0755 tl-prs-help.sh /usr/local/bin/tl-prs-help
COPY goss.yaml /goss.yaml
ADD --chmod=0755 https://github.com/goss-org/goss/releases/download/v0.4.9/goss-linux-amd64 /usr/local/bin/goss
COPY run_tlprs.R /usr/local/bin/run_tlprs.R
USER user
CMD ["tl-prs-help"]
