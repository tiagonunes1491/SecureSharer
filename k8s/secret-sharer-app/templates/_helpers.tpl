{{/*
Expand the name of the chart.
*/}}
{{- define "secret-sharer-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "secret-sharer-app.fullname" -}}
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
{{- define "secret-sharer-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "secret-sharer-app.labels" -}}
helm.sh/chart: {{ include "secret-sharer-app.chart" . }}
{{ include "secret-sharer-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "secret-sharer-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "secret-sharer-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account for the backend
*/}}
{{- define "secret-sharer-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{- default (printf "%s-sa" (include "secret-sharer-app.fullname" .)) .Values.serviceAccount.name -}}
{{- else -}}
    {{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}