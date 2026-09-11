FROM ubuntu:22.04

LABEL maintainer="Chioma <chiomabonyido@gmail.com>"

# Set environment variable for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Update system and install necessary dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
RUN useradd -m -d /xpblup user
WORKDIR /xpblup

# Download and install Plink
RUN wget https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20241013.zip \
    && unzip plink_linux_x86_64_20241013.zip \
    && mv plink /usr/local/bin/ \
    && rm plink_linux_x86_64_20241013.zip

# Download and install GCTA
RUN wget https://yanglab.westlake.edu.cn/software/gcta/bin/gcta-1.94.4-linux-kernel-3-x86_64.zip \
    && unzip gcta-1.94.4-linux-kernel-3-x86_64.zip \
    && mv gcta-1.94.4-linux-kernel-3-x86_64/gcta64 /usr/local/bin/ \
    && rm -rf gcta-1.94.4-linux-kernel-3-x86_64.zip gcta-1.94.4-linux-kernel-3-x86_64

# Download XP-BLUP
RUN wget -O xp-blup.zip https://github.com/tanglab/XP-BLUP/archive/refs/heads/master.zip \
    && unzip xp-blup.zip \
    && mv XP-BLUP-master/* ./ \
    && rm -rf xp-blup.zip XP-BLUP-master example_data

# Make bash script executable
RUN chmod +x xpblup.sh

# Adjust ownership and switch to non-root user
RUN chown -R user:user /xpblup
USER user

# Default command to start a bash shell

COPY --chmod=0755 xpblup-help.sh /usr/local/bin/xpblup-help
COPY goss.yaml /goss.yaml
ADD --chmod=0755 https://github.com/goss-org/goss/releases/download/v0.4.9/goss-linux-amd64 /usr/local/bin/goss
USER user
CMD ["xpblup-help"]
