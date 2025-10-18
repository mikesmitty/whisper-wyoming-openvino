{{/*
Expand the name of the chart.
*/}}
{{- define "whisper-wyoming.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "whisper-wyoming.fullname" -}}
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
{{- define "whisper-wyoming.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "whisper-wyoming.labels" -}}
helm.sh/chart: {{ include "whisper-wyoming.chart" . }}
{{ include "whisper-wyoming.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "whisper-wyoming.selectorLabels" -}}
app.kubernetes.io/name: {{ include "whisper-wyoming.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Whisper-cpp specific labels
*/}}
{{- define "whisper-wyoming.whisperCppLabels" -}}
{{ include "whisper-wyoming.labels" . }}
app.kubernetes.io/component: whisper-cpp
{{- end }}

{{/*
Whisper-cpp selector labels
*/}}
{{- define "whisper-wyoming.whisperCppSelectorLabels" -}}
{{ include "whisper-wyoming.selectorLabels" . }}
app.kubernetes.io/component: whisper-cpp
{{- end }}

{{/*
Wyoming-api specific labels
*/}}
{{- define "whisper-wyoming.wyomingApiLabels" -}}
{{ include "whisper-wyoming.labels" . }}
app.kubernetes.io/component: wyoming-api
{{- end }}

{{/*
Wyoming-api selector labels
*/}}
{{- define "whisper-wyoming.wyomingApiSelectorLabels" -}}
{{ include "whisper-wyoming.selectorLabels" . }}
app.kubernetes.io/component: wyoming-api
{{- end }}
