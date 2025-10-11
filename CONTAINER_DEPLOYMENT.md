# Whisper Container Deployment Guide

This guide explains how to deploy the OpenAI Whisper project using Podman containers.

## Prerequisites

- [Podman](https://podman.io/docs/installation) installed on your system
- Basic familiarity with container concepts

## Quick Start

### 1. Build the Container Image

```bash
./deploy.sh build
```

This will:
- Check if Podman is installed
- Create necessary directories
- Build the Whisper container image with all dependencies

### 2. Test the Container

```bash
./deploy.sh test
```

Verifies that:
- Whisper CLI is working
- Python module can be imported
- All dependencies are correctly installed

### 3. Run Interactively

```bash
./deploy.sh run
```

Opens an interactive shell inside the container where you can:
- Run whisper commands
- Access mounted directories
- Debug and experiment

### 4. Transcribe Audio Files

```bash
# Basic transcription
./deploy.sh transcribe path/to/audio.mp3

# With specific model
./deploy.sh transcribe path/to/audio.mp3 medium

# With custom output directory
./deploy.sh transcribe path/to/audio.mp3 base ./my_output
```

## Deployment Options

### Option 1: Simple Container Run

For one-off transcription tasks:

```bash
podman run --rm -it \
  -v "$(pwd)/whisper_models:/models:Z" \
  -v "$(pwd)/audio_input:/input:Z,ro" \
  -v "$(pwd)/audio_output:/output:Z" \
  whisper:latest \
  whisper /input/audio.mp3 --model base --output_dir /output
```

### Option 2: Kubernetes-style Deployment

For persistent deployment with resource management:

```bash
./deploy.sh deploy
```

This uses `podman play kube` with the `whisper-kube.yaml` configuration.

### Option 3: Docker Compose (Podman Compose)

If you have podman-compose installed:

```bash
podman-compose up
```

## Directory Structure

The deployment creates the following directories:

```
whisper/
├── whisper_models/     # Model cache (persistent)
├── audio_input/        # Input audio files
├── audio_output/       # Transcription outputs
├── data/              # General data directory
├── Containerfile      # Container build instructions
├── whisper-kube.yaml  # Kubernetes deployment
├── docker-compose.yml # Compose file
└── deploy.sh          # Deployment script
```

## Volume Mounts

- `/models` - Whisper model cache (persistent storage)
- `/input` - Read-only input directory for audio files
- `/output` - Output directory for transcriptions
- `/data` - General working directory

## Container Features

### Security
- Runs as non-root user (UID 1000)
- Minimal required capabilities
- Read-only root filesystem where possible
- No privilege escalation

### Performance
- Multi-stage build for smaller image size
- Proper layer caching for faster rebuilds
- Resource limits and requests defined
- Health checks for reliability

### Monitoring
- Health checks via `whisper --help`
- Readiness probes for Python module
- Proper logging configuration

## Common Use Cases

### 1. Batch Processing

Process multiple audio files:

```bash
# Copy files to input directory
cp *.mp3 audio_input/

# Run batch processing
podman run --rm \
  -v "$(pwd)/whisper_models:/models:Z" \
  -v "$(pwd)/audio_input:/input:Z,ro" \
  -v "$(pwd)/audio_output:/output:Z" \
  whisper:latest \
  find /input -name "*.mp3" -exec whisper {} --model base --output_dir /output \;
```

### 2. Web Service

Start a persistent container for web service integration:

```bash
podman run -d --name whisper-service \
  -v "$(pwd)/whisper_models:/models:Z" \
  -v "$(pwd)/data:/data:Z" \
  -p 8080:8080 \
  whisper:latest \
  python3 -m http.server 8080 --directory /data
```

### 3. Development Environment

For development with live code changes:

```bash
podman run -it --rm \
  -v "$(pwd):/workspace:Z" \
  -v "$(pwd)/whisper_models:/models:Z" \
  -w /workspace \
  whisper:latest \
  /bin/bash
```

## Environment Variables

- `WHISPER_CACHE_DIR=/models` - Model cache location
- `PYTHONUNBUFFERED=1` - Unbuffered Python output
- `PYTHONDONTWRITEBYTECODE=1` - Disable .pyc files

## Troubleshooting

### Build Issues

1. **Permission denied**: Ensure Podman is properly installed and you have permissions
2. **Network issues**: Check if you can access external repositories
3. **Space issues**: Ensure sufficient disk space for the build

### Runtime Issues

1. **Model download fails**: 
   - Check network connectivity
   - Ensure models directory is writable
   - Try smaller models first (base, small)

2. **Audio file not found**:
   - Verify file is in `audio_input/` directory
   - Check file permissions and format

3. **Container won't start**:
   - Check logs: `podman logs whisper-pod-whisper`
   - Verify image was built successfully: `podman images`

### Performance Issues

1. **Slow transcription**:
   - Increase CPU/memory limits in YAML
   - Use smaller models for faster processing
   - Ensure sufficient RAM allocation

2. **Container resource issues**:
   - Monitor with: `podman stats`
   - Adjust resource limits in deployment files

## Cleanup

Remove all containers and images:

```bash
./deploy.sh cleanup
podman rmi whisper:latest
```

## Advanced Configuration

### Custom Models

To use custom models, place them in the `whisper_models/` directory and reference them by filename.

### GPU Support

For GPU acceleration (if available):

```bash
podman run --device nvidia.com/gpu=all \
  -v "$(pwd)/whisper_models:/models:Z" \
  whisper:latest \
  whisper audio.mp3 --model base --device cuda
```

### Networking

For network access (downloading models):

```bash
podman run --network=host \
  -v "$(pwd)/whisper_models:/models:Z" \
  whisper:latest \
  whisper audio.mp3 --model base
```

## Integration Examples

### Shell Script Integration

```bash
#!/bin/bash
for audio in *.mp3; do
  podman run --rm \
    -v "$(pwd)/whisper_models:/models:Z" \
    -v "$(pwd):/workspace:Z" \
    whisper:latest \
    whisper "/workspace/$audio" --model base --output_dir /workspace
done
```

### Python Script Integration

```python
import subprocess
import os

def transcribe_with_container(audio_file, model="base"):
    cmd = [
        "podman", "run", "--rm",
        "-v", f"{os.getcwd()}/whisper_models:/models:Z",
        "-v", f"{os.getcwd()}:/workspace:Z",
        "whisper:latest",
        "whisper", f"/workspace/{audio_file}",
        "--model", model,
        "--output_dir", "/workspace"
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout, result.stderr
```

This deployment approach provides a robust, scalable, and secure way to run Whisper in containerized environments.