{{- define "todoapp.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "todoapp.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}

{{- define "todoapp.labels" -}}
app.kubernetes.io/name: {{ include "todoapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}