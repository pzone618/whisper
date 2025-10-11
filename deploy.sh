#!/bin/bash

# Whisper Container Deployment Script
# This script helps deploy the Whisper project using Podman

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if podman is installed
check_podman() {
    if ! command -v podman &> /dev/null; then
        print_error "Podman is not installed. Please install Podman first."
        print_status "Installation guide: https://podman.io/docs/installation"
        exit 1
    fi
    print_success "Podman is installed: $(podman --version)"
}

# Create necessary directories
create_directories() {
    print_status "Creating required directories..."
    mkdir -p whisper_models data audio_input audio_output
    print_success "Directories created successfully"
}

# Build the container image
build_image() {
    print_status "Building Whisper container image..."
    podman build -t whisper:latest -f Containerfile .
    
    if [ $? -eq 0 ]; then
        print_success "Container image built successfully"
    else
        print_error "Failed to build container image"
        exit 1
    fi
}

# Run container interactively
run_interactive() {
    print_status "Running Whisper container interactively..."
    
    podman run -it --rm \
        --name whisper-interactive \
        -v "$(pwd)/whisper_models:/models:Z" \
        -v "$(pwd)/data:/data:Z" \
        -v "$(pwd)/audio_input:/input:Z,ro" \
        -v "$(pwd)/audio_output:/output:Z" \
        -e WHISPER_CACHE_DIR=/models \
        whisper:latest /bin/bash
}

# Test whisper functionality
test_whisper() {
    print_status "Testing Whisper container..."
    
    # Test 1: Check if whisper command is available
    podman run --rm \
        -v "$(pwd)/whisper_models:/models:Z" \
        whisper:latest whisper --help > /dev/null
    
    if [ $? -eq 0 ]; then
        print_success "Whisper CLI is working correctly"
    else
        print_error "Whisper CLI test failed"
        return 1
    fi
    
    # Test 2: Check Python import
    podman run --rm \
        whisper:latest python3 -c "import whisper; print('Whisper module imported successfully')"
    
    if [ $? -eq 0 ]; then
        print_success "Whisper Python module is working correctly"
    else
        print_error "Whisper Python module test failed"
        return 1
    fi
}

# Deploy using Kubernetes YAML
deploy_kube() {
    print_status "Deploying with Podman Kube Play..."
    
    # Check if whisper-kube.yaml exists
    if [ ! -f "whisper-kube.yaml" ]; then
        print_error "whisper-kube.yaml not found"
        exit 1
    fi
    
    podman play kube whisper-kube.yaml
    
    if [ $? -eq 0 ]; then
        print_success "Deployed successfully with Podman Kube Play"
        print_status "Use 'podman pod list' to check pod status"
        print_status "Use 'podman logs whisper-pod-whisper' to view logs"
    else
        print_error "Deployment failed"
        exit 1
    fi
}

# Stop and remove deployment
cleanup() {
    print_status "Cleaning up Whisper deployment..."
    
    # Stop and remove pod
    podman play kube --down whisper-kube.yaml 2>/dev/null || true
    
    # Remove any running containers
    podman rm -f whisper-interactive 2>/dev/null || true
    
    print_success "Cleanup completed"
}

# Transcribe audio file
transcribe_audio() {
    local audio_file="$1"
    local model="${2:-base}"
    local output_dir="${3:-./audio_output}"
    
    if [ ! -f "$audio_file" ]; then
        print_error "Audio file '$audio_file' not found"
        exit 1
    fi
    
    print_status "Transcribing $audio_file with model $model..."
    
    # Copy audio file to input directory
    cp "$audio_file" audio_input/
    local filename=$(basename "$audio_file")
    
    # Run transcription
    podman run --rm \
        -v "$(pwd)/whisper_models:/models:Z" \
        -v "$(pwd)/audio_input:/input:Z,ro" \
        -v "$(pwd)/audio_output:/output:Z" \
        -e WHISPER_CACHE_DIR=/models \
        whisper:latest \
        whisper "/input/$filename" --model "$model" --output_dir /output
    
    if [ $? -eq 0 ]; then
        print_success "Transcription completed. Check $output_dir for results."
    else
        print_error "Transcription failed"
        exit 1
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  build           - Build the Whisper container image"
    echo "  test            - Test the Whisper container functionality"
    echo "  run             - Run Whisper container interactively"
    echo "  deploy          - Deploy using Podman Kube Play"
    echo "  cleanup         - Stop and remove deployment"
    echo "  transcribe      - Transcribe an audio file"
    echo "  help            - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 test"
    echo "  $0 run"
    echo "  $0 deploy"
    echo "  $0 transcribe audio.mp3 base"
    echo "  $0 cleanup"
}

# Main function
main() {
    case "${1:-help}" in
        build)
            check_podman
            create_directories
            build_image
            ;;
        test)
            check_podman
            test_whisper
            ;;
        run)
            check_podman
            create_directories
            run_interactive
            ;;
        deploy)
            check_podman
            create_directories
            deploy_kube
            ;;
        cleanup)
            check_podman
            cleanup
            ;;
        transcribe)
            if [ $# -lt 2 ]; then
                print_error "Audio file path required for transcription"
                echo "Usage: $0 transcribe <audio_file> [model] [output_dir]"
                exit 1
            fi
            check_podman
            create_directories
            transcribe_audio "${2}" "${3:-base}" "${4:-./audio_output}"
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            print_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"