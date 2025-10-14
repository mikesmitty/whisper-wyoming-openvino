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

Install the chart with the release name `whisper-wyoming`:

```bash
helm install whisper-wyoming ./helm/whisper-wyoming
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

Install with custom values:

```bash
helm install whisper-wyoming ./helm/whisper-wyoming -f custom-values.yaml
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

- `tiny.en` - Smallest, fastest, least accurate (~75MB)
- `tiny` - Multilingual version of tiny
- `base.en` - Good balance of speed and accuracy (~140MB) 
- `base` - Multilingual base model
- `small.en` - Better accuracy (~470MB)
- `small` - Multilingual small model
- `medium.en` - High accuracy (~1.5GB)
- `medium` - Multilingual medium model
- `large-v3` - Best accuracy, slowest (~3GB)

## Usage

### Accessing the Wyoming API

After installation, get connection details:

```bash
helm status whisper-wyoming
```

For ClusterIP service, port-forward to access:

```bash
kubectl port-forward svc/whisper-wyoming-wyoming-api 7891:7891
```

### Using with Home Assistant

Add to your Home Assistant `configuration.yaml`:

```yaml
wyoming:
  - platform: whisper
    host: whisper-wyoming-wyoming-api.default.svc.cluster.local
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

To uninstall/delete the `whisper-wyoming` deployment:

```bash
helm uninstall whisper-wyoming
```

To also delete the PVC:

```bash
kubectl delete pvc whisper-wyoming-models
```

## References

- [Whisper.cpp](https://github.com/ggml-org/whisper.cpp)
- [Wyoming Protocol](https://github.com/rhasspy/wyoming)
- [Wyoming Whisper API Client](https://github.com/ser/wyoming-whisper-api-client)
- [Intel GPU Device Plugin](https://github.com/intel/intel-device-plugins-for-kubernetes)
- [Docker Compose Reference](https://github.com/tannisroot/wyoming-whisper-cpp-intel-gpu-docker)
