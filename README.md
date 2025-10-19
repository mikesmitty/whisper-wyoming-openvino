# whisper-wyoming-openvino

Kubernetes Helm chart for deploying Whisper.cpp speech-to-text with Wyoming protocol support, optimized for Intel GPU hardware.

## Features

- **Intel GPU Acceleration** - Uses `ghcr.io/ggml-org/whisper.cpp:main-intel` image with Intel i915 GPU support
- **Wyoming Protocol** - Compatible with Home Assistant and other Wyoming clients
- **Auto Model Download** - Automatically downloads Whisper models on first run
- **Persistent Storage** - Stores models in PersistentVolumeClaim for fast restarts
- **Security** - Runs as non-root with minimal privileges
- **Production Ready** - Includes health checks, resource limits, and proper Kubernetes configuration

## Quick Start

### Prerequisites

- Kubernetes cluster with Intel GPU nodes
- Intel GPU device plugin installed
- Helm 3.0+

### Installation

#### Option 1: Install from OCI Registry (Recommended)

```bash
# Install the Helm chart from GHCR
helm install whisper-wyoming-openvino oci://ghcr.io/mikesmitty/whisper-wyoming-openvino --version 0.1.0

# Check the status
helm status whisper-wyoming-openvino

# Access the Wyoming API (port-forward for ClusterIP)
kubectl port-forward svc/whisper-wyoming-openvino-wyoming-api 7891:7891
```

#### Option 2: Install from source

```bash
# Clone the repository
git clone https://github.com/mikesmitty/whisper-wyoming-openvino.git
cd whisper-wyoming-openvino

# Install the Helm chart
helm install whisper-wyoming-openvino ./charts/whisper-wyoming-openvino

# Check the status
helm status whisper-wyoming-openvino

# Access the Wyoming API (port-forward for ClusterIP)
kubectl port-forward svc/whisper-wyoming-openvino-wyoming-api 7891:7891
```

## Documentation

See the [Helm chart README](charts/whisper-wyoming-openvino/README.md) for detailed configuration options and usage instructions.

## Architecture

This deployment consists of two main components:

1. **Whisper.cpp Server** - Runs the Whisper inference engine with Intel GPU acceleration
2. **Wyoming API Client** - Provides Wyoming protocol compatibility for Home Assistant integration

Both components run in separate pods with appropriate resource limits and security contexts.

## References

- [Whisper.cpp](https://github.com/ggml-org/whisper.cpp) - Whisper inference engine
- [Wyoming Protocol](https://github.com/rhasspy/wyoming) - Speech-to-text protocol
- [Wyoming Whisper API Client](https://github.com/ser/wyoming-whisper-api-client) - Wyoming adapter
- [Docker Compose Reference](https://github.com/tannisroot/wyoming-whisper-cpp-intel-gpu-docker) - Inspiration for this deployment