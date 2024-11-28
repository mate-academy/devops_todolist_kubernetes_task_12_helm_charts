{{/*
Expand the name of the chart, prepending the release name and using the chart name as a prefix.
*/}}
{{- define "todoapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fullname for resources based on the release name and chart name.
*/}}
{{- define "todoapp.fullname" -}}
{{- if and (not (empty .Values.fullnameOverride)) (ne .Values.fullnameOverride "") }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- printf "%s-%s" .Release.Name (include "todoapp.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end -}}

{{/*
Generate labels for the app, using common labels and chart details.
*/}}
{{- define "todoapp.labels" -}}
app.kubernetes.io/name: {{ include "todoapp.name" . }}
helm.sh/chart: {{ include "todoapp.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Return the chart name and version.
*/}}
{{- define "todoapp.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}

{{/*
Create a name for the service account, using the release name and chart name.
*/}}
{{- define "todoapp.serviceAccountName" -}}
{{- if .Values.serviceAccount.name }}
{{- .Values.serviceAccount.name | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- printf "%s-%s" .Release.Name "serviceaccount" | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end -}}

{{/*
Generate the selector labels for selecting the appropriate pods.
*/}}
{{- define "todoapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "todoapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
