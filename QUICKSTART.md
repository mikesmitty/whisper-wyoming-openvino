# Quick Start Guide

## Prerequisites

Before installing this Helm chart, ensure your Kubernetes cluster has:

1. **Intel GPU Device Plugin** installed:
   ```bash
   # Install NFD (Node Feature Discovery)
   kubectl apply -k https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/nfd?ref=main
   
   # Install Intel GPU Device Plugin
   kubectl apply -k https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/gpu_plugin?ref=main
   ```

2. **Verify GPU availability** on your nodes:
   ```bash
   kubectl get nodes -o json | jq '.items[].status.allocatable | select(."gpu.intel.com/i915" != null)'
   ```

3. **Helm 3.0+** installed:
   ```bash
   helm version
   ```

## Installation Steps

### 1. Clone the repository
```bash
git clone https://github.com/mikesmitty/whisper-wyoming-openvino.git
cd whisper-wyoming-openvino
```

### 2. Install with default settings
```bash
helm install whisper-wyoming ./helm/whisper-wyoming
```

This will:
- Deploy Whisper.cpp with base.en model
- Set up Wyoming API service
- Create a 10Gi PVC for model storage
- Configure Intel GPU (i915) resource claims

### 3. Check the installation
```bash
# Check deployment status
helm status whisper-wyoming

# Watch pods start
kubectl get pods -w -l app.kubernetes.io/instance=whisper-wyoming

# Check logs (Whisper.cpp)
kubectl logs -l app.kubernetes.io/component=whisper-cpp -f

# Check logs (Wyoming API)
kubectl logs -l app.kubernetes.io/component=wyoming-api -f
```

### 4. Access the service

#### Option A: Port Forward (for testing)
```bash
kubectl port-forward svc/whisper-wyoming-wyoming-api 7891:7891
```
Then access at: `tcp://127.0.0.1:7891`

#### Option B: LoadBalancer (for production)
Create a custom values file:
```yaml
# custom-values.yaml
wyomingApi:
  service:
    type: LoadBalancer
```

Install with custom values:
```bash
helm install whisper-wyoming ./helm/whisper-wyoming -f custom-values.yaml
```

Get the external IP:
```bash
kubectl get svc whisper-wyoming-wyoming-api
```

## Customization Examples

### Use a different model
```yaml
# values-custom.yaml
whisperCpp:
  model: small.en  # Options: tiny.en, base.en, small.en, medium.en, large-v3
```

### Increase storage
```yaml
# values-custom.yaml
persistence:
  size: 20Gi
  storageClass: "fast-ssd"  # Your storage class
```

### Schedule on specific nodes
```yaml
# values-custom.yaml
nodeSelector:
  intel.feature.node.kubernetes.io/gpu: "true"
```

Install with customizations:
```bash
helm install whisper-wyoming ./helm/whisper-wyoming -f values-custom.yaml
```

## Integration with Home Assistant

Add to your Home Assistant `configuration.yaml`:

```yaml
wyoming:
  - platform: whisper
    host: whisper-wyoming-wyoming-api.default.svc.cluster.local  # For in-cluster
    port: 7891
```

Or if using LoadBalancer:
```yaml
wyoming:
  - platform: whisper
    host: <EXTERNAL_IP>  # From kubectl get svc
    port: 7891
```

## Troubleshooting

### Pods not starting?
```bash
# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check pod status
kubectl describe pod -l app.kubernetes.io/instance=whisper-wyoming
```

### Model download failing?
```bash
# Check init container logs
POD=$(kubectl get pod -l app.kubernetes.io/component=whisper-cpp -o jsonpath='{.items[0].metadata.name}')
kubectl logs $POD -c model-download
```

### GPU not detected?
```bash
# Verify GPU plugin is running
kubectl get pods -n kube-system | grep intel-gpu-plugin

# Check node GPU resources
kubectl describe node <node-name> | grep gpu.intel.com/i915
```

## Upgrading

```bash
# Update values
helm upgrade whisper-wyoming ./helm/whisper-wyoming -f custom-values.yaml

# Check upgrade status
helm status whisper-wyoming
```

## Uninstalling

```bash
# Remove the release
helm uninstall whisper-wyoming

# Optionally, delete the PVC
kubectl delete pvc whisper-wyoming-models
```

## Support

For issues and questions:
- GitHub Issues: https://github.com/mikesmitty/whisper-wyoming-openvino/issues
- Detailed docs: See [helm/whisper-wyoming/README.md](helm/whisper-wyoming/README.md)
