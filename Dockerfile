# Use an official Alpine base image for a minimal footprint
FROM alpine:3.18

# Set ARGs for tool versions
ARG TERRAFORM_VERSION=v1.9.5
ARG TERRAGRUNT_VERSION=v0.67.2
ARG CHECKOV_VERSION=3.2.245
ARG TFDOCS_VERSION=v0.18.0
ARG TFLINT_VERSION=v0.53.0
ARG TFSEC_VERSION=v1.28.10

# Install necessary dependencies
RUN apk --no-cache add \
    bash \
    curl \
    git \
    jq \
    unzip \
    python3 \
    py3-pip \
    py3-virtualenv \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev

# Upgrade pip to the latest version to handle prebuilt wheels
RUN pip install --upgrade pip

# Install Terraform
RUN curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Terragrunt
RUN curl -LO https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
    && chmod +x terragrunt_linux_amd64 \
    && mv terragrunt_linux_amd64 /usr/local/bin/terragrunt

# Create a Python virtual environment and activate it
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Checkov inside the virtual environment
RUN pip install --no-cache-dir checkov==${CHECKOV_VERSION}

# Install Terraform Docs
RUN curl -LO https://github.com/terraform-docs/terraform-docs/releases/download/v${TFDOCS_VERSION}/terraform-docs-v${TFDOCS_VERSION}-linux-amd64.tar.gz \
    && tar -xvzf terraform-docs-v${TFDOCS_VERSION}-linux-amd64.tar.gz \
    && mv terraform-docs /usr/local/bin/ \
    && rm terraform-docs-v${TFDOCS_VERSION}-linux-amd64.tar.gz

# Install TFLint
RUN curl -LO https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip \
    && unzip tflint_linux_amd64.zip \
    && mv tflint /usr/local/bin/ \
    && rm tflint_linux_amd64.zip

# Install TFsec
RUN curl -LO https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64 \
    && chmod +x tfsec-linux-amd64 \
    && mv tfsec-linux-amd64 /usr/local/bin/tfsec

# Verify installations
RUN terraform --version && \
    terragrunt --version && \
    checkov --version && \
    terraform-docs --version && \
    tflint --version && \
    tfsec --version

# Set the default entrypoint
ENTRYPOINT ["/bin/bash"]
