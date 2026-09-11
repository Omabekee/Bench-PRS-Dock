FROM ubuntu:22.04

# Metadata
LABEL maintainer="Chioma <chiomabonyido@gmail.com>"

# Avoid tzdata prompt during install
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libxt-dev \
    build-essential \
    python3 \
    python3-pip \
    r-base \
    file \
    && wget https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20241013.zip \
    && unzip plink_linux_x86_64_20241013.zip \
    && mv plink /usr/local/bin/ \
    && rm plink_linux_x86_64_20241013.zip

# Copy Python requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip3 install -r requirements.txt

# Install R dependencies
RUN R -e 'install.packages(c("BEDMatrix", "boot", "data.table", "doMC", "glmnet", "MASS", "optparse", "parallel", "R.utils"), dependencies = TRUE, repos="http://cran.rstudio.com/")'

# Create a non-root user and workspace
RUN useradd -m user && \
    mkdir -p /BridgePRS && \
    chown -R user:user /BridgePRS

USER user

WORKDIR /BridgePRS

# Download and extract BridgePRS repo
RUN wget -O bridgeprs.zip https://github.com/clivehoggart/BridgePRS/archive/refs/heads/main.zip && \
    unzip bridgeprs.zip && \
    mv BridgePRS-main/* ./ && \
    rm bridgeprs.zip && \
    rm -rf ./data

# Make main script executable
RUN chmod +x bridgePRS

# Set default command

COPY --chmod=0755 bridgeprs-help.sh /usr/local/bin/bridgeprs-help
COPY goss.yaml /goss.yaml
ADD --chmod=0755 https://github.com/goss-org/goss/releases/download/v0.4.9/goss-linux-amd64 /usr/local/bin/goss
USER user
CMD ["bridgeprs-help"]
