FROM python:3.8-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      gcc g++ make wget unzip git ca-certificates time \
  && rm -rf /var/lib/apt/lists/*

# plink2 (unzip properly)
RUN wget -q https://s3.amazonaws.com/plink2-assets/alpha6/plink2_linux_x86_64_20250129.zip -O /tmp/plink2.zip \
  && unzip -o /tmp/plink2.zip -d /usr/local/bin/ \
  && chmod +x /usr/local/bin/plink2 \
  && rm /tmp/plink2.zip

# Python deps (scipy<1.12 for legacy numpy aliases used by JointPRS/PRScsx code)
RUN pip install --no-cache-dir cython h5py numpy 'scipy<1.12' setuptools

# Clone + build JointPRS cython extension
RUN git clone https://github.com/LeqiXu/JointPRS.git /jointprs \
  && cd /jointprs \
  && python setup.py build_ext --inplace

WORKDIR /jointprs

COPY --chmod=0755 jointprs-help.sh /usr/local/bin/jointprs-help
COPY goss.yaml /goss.yaml
ADD --chmod=0755 https://github.com/goss-org/goss/releases/download/v0.4.9/goss-linux-amd64 /usr/local/bin/goss
RUN useradd -m -u 1000 appuser
USER appuser
CMD ["jointprs-help"]
