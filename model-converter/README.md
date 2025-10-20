# Model Converter Image

This Docker image contains UV and all the dependencies needed to convert Whisper models to OpenVINO format.

## Pre-installed Dependencies

- Python 3.12
- UV (Python package installer)
- openvino-dev[pytorch,onnx]
- openai-whisper
- onnxscript
- torch

## Building the Image

```bash
docker build -t ghcr.io/mikesmitty/whisper-model-converter:latest .
```

## Pushing the Image

```bash
docker push ghcr.io/mikesmitty/whisper-model-converter:latest
```

## Usage

This image is designed to be used as an init container in the Helm chart. The dependencies are pre-installed, so the conversion script can run directly with Python without needing to install packages at runtime.

## Configuration

Update the `values.yaml` in the Helm chart to use this image:

```yaml
modelDownload:
  enabled: true
  image:
    repository: ghcr.io/mikesmitty/whisper-model-converter
    tag: latest
    pullPolicy: IfNotPresent
```
