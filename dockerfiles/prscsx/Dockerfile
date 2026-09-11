FROM python:3.8-slim

LABEL maintainer="Chioma <chiomabonyido@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20241013.zip \
    && unzip plink_linux_x86_64_20241013.zip \
    && mv plink /usr/local/bin/ \
    && apt-get clean \
    && rm plink_linux_x86_64_20241013.zip
    
WORKDIR /PRS-CSx

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

RUN wget -O PRScsx.zip https://github.com/getian107/PRScsx/archive/refs/heads/master.zip \
           && unzip PRScsx.zip \
           && mv PRScsx-master/* ./ \
           && rm -rf PRScsx-master PRScsx.zip \
           && mkdir -p /PRS-CSx/out \
           && rm -rf ./test_data
	   

RUN chmod +x /PRS-CSx/PRScsx.py


COPY --chmod=0755 prscsx-help.sh /usr/local/bin/prscsx-help
COPY goss.yaml /goss.yaml
ADD --chmod=0755 https://github.com/goss-org/goss/releases/download/v0.4.9/goss-linux-amd64 /usr/local/bin/goss
RUN useradd -m -u 1000 appuser
USER appuser
CMD ["prscsx-help"]
