# Multi-stage build for OpenAI Whisper
FROM registry.fedoraproject.org/fedora:39 AS base

# Install system dependencies
RUN dnf -y update && \
    dnf -y install \
        python3 \
        python3-pip \
        python3-devel \
        gcc \
        g++ \
        git \
        ffmpeg \
        ffmpeg-devel \
        && dnf clean all

# Create a non-root user for security
RUN useradd -m -u 1000 whisper && \
    mkdir -p /app /models && \
    chown -R whisper:whisper /app /models

# Set up Python environment
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Stage 2: Dependencies installation
FROM base AS deps

# Switch to non-root user
USER whisper
WORKDIR /app

# Copy only dependency files first (for better layer caching)
COPY --chown=whisper:whisper requirements.txt pyproject.toml ./

# Install Python dependencies
RUN pip3 install --user --upgrade pip setuptools wheel && \
    pip3 install --user -r requirements.txt

# Stage 3: Application
FROM base AS app

# Switch to non-root user
USER whisper
WORKDIR /app

# Copy Python packages from deps stage
COPY --from=deps --chown=whisper:whisper /home/whisper/.local /home/whisper/.local

# Copy application source code
COPY --chown=whisper:whisper . .

# Install whisper in development mode
RUN /home/whisper/.local/bin/pip install --user -e .

# Set PATH to include user-installed packages
ENV PATH="/home/whisper/.local/bin:$PATH"

# Create volume mount points for models and input/output
VOLUME ["/models", "/data"]

# Set working directory for data processing
WORKDIR /data

# Health check to verify whisper is working
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD whisper --help > /dev/null || exit 1

# Set labels for container metadata
LABEL io.containers.capabilities="CAP_DAC_OVERRIDE" \
      org.opencontainers.image.title="OpenAI Whisper" \
      org.opencontainers.image.description="Robust Speech Recognition via Large-Scale Weak Supervision" \
      org.opencontainers.image.source="https://github.com/openai/whisper" \
      org.opencontainers.image.licenses="MIT"

# Default command
CMD ["whisper", "--help"]