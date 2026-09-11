FROM continuumio/miniconda3

LABEL maintainer="Chioma <chiomabonyido@gmail.com>"

# Set environment variable for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install essential system libraries and Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    libcurl4-openssl-dev \
    libssl-dev \
    libffi-dev \
    build-essential \
    python3-dev \
    python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and install Plink
RUN wget https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20241013.zip \
    && unzip plink_linux_x86_64_20241013.zip \
    && mv plink /usr/local/bin/ \
    && rm plink_linux_x86_64_20241013.zip

# Install mamba and create Conda environment with Python 3 + requested packages
RUN conda install -y -n base -c conda-forge mamba && \
    mamba create -y -n sdprx_env -c conda-forge python=3 numpy scipy pandas=1.1.5 joblib && \
    conda clean -afy

# Add non-root user
RUN useradd -m -s /bin/bash user

# Make sure conda is initialized for bash and available in user shell
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/user/.bashrc && \
    echo "conda activate sdprx_env" >> /home/user/.bashrc && \
    chown -R user:user /home/user

# Set working directory
WORKDIR /sdprx

# Download sdprx zipped file
RUN wget -O sdprx.zip https://github.com/eldronzhou/SDPRX/archive/refs/heads/main.zip \
    && unzip sdprx.zip \
    && mv SDPRX-main/* ./ \
    && rm -rf SDPRX-main sdprx.zip ./test

# Make Python script executable
RUN chmod +x SDPRX.py

# Adjust ownership and switch to non-root user
RUN chown -R user:user /sdprx
USER user

# Start interactive bash shell with env activated

COPY --chmod=0755 sdprx-help.sh /usr/local/bin/sdprx-help
COPY goss.yaml /goss.yaml
ADD --chmod=0755 https://github.com/goss-org/goss/releases/download/v0.4.9/goss-linux-amd64 /usr/local/bin/goss
USER user
CMD ["sdprx-help"]
