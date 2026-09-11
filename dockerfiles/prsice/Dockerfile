FROM rocker/r-ver:4.1.2

RUN apt-get update && apt-get install -y --no-install-recommends \
        wget unzip ca-certificates && rm -rf /var/lib/apt/lists/*

# PRSice R dependencies (data.table + ggplot2)
RUN R -e "install.packages(c('data.table','ggplot2'), repos='http://cran.rstudio.com/')"

# PRSice-2 release (binary + R wrapper)
WORKDIR /opt/prsice
RUN wget -q https://github.com/choishingwan/PRSice/releases/download/2.3.5/PRSice_linux.zip -O PRSice_linux.zip \
    && unzip -oq PRSice_linux.zip \
    && cp PRSice_linux /usr/local/bin/PRSice \
    && cp PRSice.R   /usr/local/bin/PRSice.R \
    && chmod +x /usr/local/bin/PRSice

RUN apt-get update && apt-get install -y --no-install-recommends time && rm -rf /var/lib/apt/lists/*

COPY --chmod=0755 prsice-help.sh /usr/local/bin/prsice-help
COPY goss.yaml /goss.yaml
ADD --chmod=0755 https://github.com/goss-org/goss/releases/download/v0.4.9/goss-linux-amd64 /usr/local/bin/goss
RUN useradd -m -u 1000 appuser
USER appuser
CMD ["prsice-help"]
