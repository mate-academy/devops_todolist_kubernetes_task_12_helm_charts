{{- define "todoapp.fullname" -}}
{{- printf "%s-%s" .Chart.Name .name | trunc 63 | trimSuffix "-" -}}
{{- end -}}