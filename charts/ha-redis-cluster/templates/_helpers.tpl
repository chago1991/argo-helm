{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ha-redis-cluster.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ha-redis-cluster.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ha-redis-cluster.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "ha-redis-cluster.labels" -}}
helm.sh/chart: {{ include "ha-redis-cluster.chart" . }}
{{ include "ha-redis-cluster.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: ha-redis-cluster
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "ha-redis-cluster.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ha-redis-cluster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
redis-secret-init fullname
*/}}
{{- define "ha-redis-cluster.redisSecretInit.fullname" -}}
{{- printf "%s-%s" (include "ha-redis-cluster.fullname" .) .Values.redisSecretInit.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
redis-secret-init service account name
*/}}
{{- define "ha-redis-cluster.redisSecretInit.serviceAccountName" -}}
{{- if .Values.redisSecretInit.serviceAccount.create -}}
    {{ default (include "ha-redis-cluster.redisSecretInit.fullname" .) .Values.redisSecretInit.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.redisSecretInit.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
The image tag used by the secret-init Job.
This must be set explicitly via redisSecretInit.image.tag (e.g. to the Argo CD version).
*/}}
{{- define "ha-redis-cluster.redisSecretInit.imageTag" -}}
{{- required "redisSecretInit.image.tag is required when redisSecretInit.enabled=true. Set it to the Argo CD version (e.g. v2.12.0)." .Values.redisSecretInit.image.tag -}}
{{- end -}}
