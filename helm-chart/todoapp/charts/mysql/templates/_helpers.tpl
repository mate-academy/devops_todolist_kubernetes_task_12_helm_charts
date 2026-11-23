{{- define "mysql.namespace" -}}
{{ .Chart.Name }}-{{ .Values.mysql.namespace }}
{{- end }}
