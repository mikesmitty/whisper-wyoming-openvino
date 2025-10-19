{{/*
Expand the name of the chart.
*/}}
{{- define "whisper-wyoming-openvino.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "whisper-wyoming-openvino.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "whisper-wyoming-openvino.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "whisper-wyoming-openvino.labels" -}}
helm.sh/chart: {{ include "whisper-wyoming-openvino.chart" . }}
{{ include "whisper-wyoming-openvino.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "whisper-wyoming-openvino.selectorLabels" -}}
app.kubernetes.io/name: {{ include "whisper-wyoming-openvino.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Whisper-cpp specific labels
*/}}
{{- define "whisper-wyoming-openvino.whisperCppLabels" -}}
{{ include "whisper-wyoming-openvino.labels" . }}
app.kubernetes.io/component: whisper-cpp
{{- end }}

{{/*
Whisper-cpp selector labels
*/}}
{{- define "whisper-wyoming-openvino.whisperCppSelectorLabels" -}}
{{ include "whisper-wyoming-openvino.selectorLabels" . }}
app.kubernetes.io/component: whisper-cpp
{{- end }}

{{/*
Wyoming-api specific labels
*/}}
{{- define "whisper-wyoming-openvino.wyomingApiLabels" -}}
{{ include "whisper-wyoming-openvino.labels" . }}
app.kubernetes.io/component: wyoming-api
{{- end }}

{{/*
Wyoming-api selector labels
*/}}
{{- define "whisper-wyoming-openvino.wyomingApiSelectorLabels" -}}
{{ include "whisper-wyoming-openvino.selectorLabels" . }}
app.kubernetes.io/component: wyoming-api
{{- end }}
