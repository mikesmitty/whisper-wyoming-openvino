# Whisper Wyoming Helm Chart

This Helm chart deploys a Whisper.cpp speech-to-text service with Wyoming protocol support on Kubernetes, optimized for Intel GPU hardware.

## Overview

This chart combines:
- **Whisper.cpp** (`ghcr.io/ggml-org/whisper.cpp:main-intel`) - OpenAI Whisper implementation with Intel GPU acceleration
- **Wyoming API Client** - Protocol adapter for Home Assistant and other Wyoming-compatible clients
- **Intel GPU Support** - Uses Kubernetes `gpu.intel.com/i915` resource claims for hardware acceleration

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Intel GPU with i915 driver on worker nodes
- Intel GPU device plugin installed in your cluster
  ```bash
  kubectl apply -k https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/nfd?ref=main
  kubectl apply -k https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/gpu_plugin?ref=main
  ```

## Installation

### Quick Start

#### Option 1: Install from OCI Registry (Recommended)

Install the chart from GitHub Container Registry with the release name `whisper-wyoming-openvino`:

```bash
helm install whisper-wyoming-openvino oci://ghcr.io/mikesmitty/whisper-wyoming-openvino --version 0.1.0
```

#### Option 2: Install from source

Install the chart from a local clone:

```bash
git clone https://github.com/mikesmitty/whisper-wyoming-openvino.git
cd whisper-wyoming-openvino
helm install whisper-wyoming-openvino ./charts/whisper-wyoming-openvino
```

### Custom Configuration

Create a `custom-values.yaml` file:

```yaml
whisperCpp:
  model: large-v3-turbo  # See "Available Whisper Models" section below for full list
  language: en
  beamSize: 5

wyomingApi:
  service:
    type: LoadBalancer  # Expose externally

persistence:
  enabled: true
  size: 20Gi
  storageClass: "fast-ssd"

nodeSelector:
  intel.feature.node.kubernetes.io/gpu: "true"
```

Install with custom values from OCI registry:

```bash
helm install whisper-wyoming-openvino oci://ghcr.io/mikesmitty/whisper-wyoming-openvino --version 0.1.0 -f custom-values.yaml
```

Or from source:

```bash
helm install whisper-wyoming-openvino ./charts/whisper-wyoming-openvino -f custom-values.yaml
```

## Configuration

The following table lists the configurable parameters:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `whisperCpp.image.repository` | Whisper.cpp image repository | `ghcr.io/ggml-org/whisper.cpp` |
| `whisperCpp.image.tag` | Whisper.cpp image tag | `main-intel` |
| `whisperCpp.model` | Whisper model to use | `base.en` |
| `whisperCpp.language` | Language code | `en` |
| `whisperCpp.beamSize` | Beam search size | `5` |
| `whisperCpp.service.type` | Service type | `ClusterIP` |
| `whisperCpp.service.port` | Service port | `8910` |
| `whisperCpp.resources.limits` | Resource limits | `{gpu.intel.com/i915: 1}` |
| `wyomingApi.image.repository` | Wyoming API image repository | `ghcr.io/ser/wyoming-whisper-api-client` |
| `wyomingApi.image.tag` | Wyoming API image tag | `latest` |
| `wyomingApi.service.type` | Service type | `ClusterIP` |
| `wyomingApi.service.port` | Service port | `7891` |
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.size` | PVC size | `10Gi` |
| `persistence.storageClass` | Storage class | `""` |
| `nodeSelector` | Node selector | `{}` |

## Available Whisper Models

The following models are automatically converted to OpenVINO format on first run for optimal Intel GPU performance:

**Multilingual Models:**
- `tiny` - Smallest model, fastest inference, lower accuracy (~75MB)
- `base` - Small model, good balance of speed and accuracy (~142MB)
- `small` - Medium model, better accuracy (~466MB)
- `medium` - Large model, high accuracy (~1.5GB)
- `large-v1` - Very large model, highest accuracy (v1) (~2.9GB)
- `large-v2` - Very large model, highest accuracy (v2) (~2.9GB)
- `large-v3` - Very large model, highest accuracy (v3) (~2.9GB)
- `large-v3-turbo` - Optimized large model for faster inference (default) (~1.6GB)

**English-Only Models (better accuracy for English):**
- `tiny.en` - Smallest English-only model (~75MB)
- `base.en` - Small English-only model (~142MB)
- `small.en` - Medium English-only model (~466MB)
- `medium.en` - Large English-only model (~1.5GB)

### Model Selection Guide

- **For fastest inference**: Use `tiny` or `tiny.en`
- **For best quality**: Use `large-v3` or `large-v3-turbo`
- **For English-only (recommended)**: Use `.en` variants for better accuracy
- **Recommended default**: `large-v3-turbo` (best balance of speed and accuracy)

**Note:** The init container automatically downloads the base model from HuggingFace and converts it to OpenVINO format. The conversion happens once and the resulting OpenVINO model is cached in persistent storage. Quantized models are not supported with OpenVINO conversion.

## Usage

### Accessing the Wyoming API

After installation, get connection details:

```bash
helm status whisper-wyoming-openvino
```

For ClusterIP service, port-forward to access:

```bash
kubectl port-forward svc/whisper-wyoming-openvino-wyoming-api 7891:7891
```

### Using with Home Assistant

Add to your Home Assistant `configuration.yaml`:

```yaml
wyoming:
  - platform: whisper
    host: whisper-wyoming-openvino-wyoming-api.default.svc.cluster.local
    port: 7891
```

Or if exposed externally:

```yaml
wyoming:
  - platform: whisper
    host: <EXTERNAL_IP>
    port: 7891
```

## Troubleshooting

### Check if Intel GPU is available

```bash
kubectl get nodes -o json | jq '.items[].status.allocatable | select(."gpu.intel.com/i915" != null)'
```

### View logs

```bash
# Whisper.cpp logs
kubectl logs -l app.kubernetes.io/component=whisper-cpp

# Wyoming API logs
kubectl logs -l app.kubernetes.io/component=wyoming-api
```

### Model download issues

If the model fails to download, check init container logs:

```bash
kubectl logs <pod-name> -c model-download
```

### Intel GPU not detected

Ensure the Intel GPU device plugin is running:

```bash
kubectl get pods -n kube-system | grep intel-gpu-plugin
```

## Uninstallation

To uninstall/delete the `whisper-wyoming-openvino` deployment:

```bash
helm uninstall whisper-wyoming-openvino
```

To also delete the PVC:

```bash
kubectl delete pvc whisper-wyoming-openvino-models
```

## References

- [Whisper.cpp](https://github.com/ggml-org/whisper.cpp)
- [Wyoming Protocol](https://github.com/rhasspy/wyoming)
- [Wyoming Whisper API Client](https://github.com/ser/wyoming-whisper-api-client)
- [Intel GPU Device Plugin](https://github.com/intel/intel-device-plugins-for-kubernetes)
- [Docker Compose Reference](https://github.com/tannisroot/wyoming-whisper-cpp-intel-gpu-docker)
