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
  model: base.en  # Options: tiny.en, base.en, small.en, medium.en, large-v3
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

OpenVINO-optimized models (recommended for Intel GPU):
- `distil-whisper-large-v3-int8-ov` - Default, good balance of quality and performance
- `distil-whisper-large-v3-int4-ov` - Smaller size, faster inference
- `distil-whisper-large-v3-fp16-ov` - Higher quality, more resources
- `distil-whisper-large-v2-int8-ov` - Previous version, int8 quantization
- `distil-whisper-large-v2-int4-ov` - Previous version, int4 quantization
- `distil-whisper-large-v2-fp16-ov` - Previous version, fp16 precision
- `whisper-large-v3-int8-ov` - Full large model, int8 quantization
- `whisper-large-v3-int4-ov` - Full large model, int4 quantization
- `whisper-large-v3-fp16-ov` - Full large model, fp16 precision
- `whisper-medium-int8-ov` - Medium model, int8 quantization
- `whisper-medium-int4-ov` - Medium model, int4 quantization
- `whisper-medium-fp16-ov` - Medium model, fp16 precision
- `whisper-medium.en-int8-ov` - Medium English-only, int8
- `whisper-medium.en-int4-ov` - Medium English-only, int4
- `whisper-medium.en-fp16-ov` - Medium English-only, fp16
- `whisper-base-int8-ov` - Base model, int8 quantization
- `whisper-base-int4-ov` - Base model, int4 quantization
- `whisper-base-fp16-ov` - Base model, fp16 precision
- `whisper-tiny-int8-ov` - Tiny model, int8 quantization
- `whisper-tiny-int4-ov` - Tiny model, int4 quantization
- `whisper-tiny-fp16-ov` - Tiny model, fp16 precision

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
