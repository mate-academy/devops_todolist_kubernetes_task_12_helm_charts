{{- define "todoapp.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "todoapp.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "todoapp.labels" -}}
app.kubernetes.io/name: {{ include "todoapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | default "1.0.0" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

