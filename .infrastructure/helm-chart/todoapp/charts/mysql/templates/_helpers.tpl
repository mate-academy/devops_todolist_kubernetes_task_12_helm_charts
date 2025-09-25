{{- define "mysql.fullname" -}}
{{ printf "%s-%s" .Chart.Name (default .Release.Name .Release.Name) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "mysql.name" -}}
{{ .Chart.Name }}
{{- end -}}
