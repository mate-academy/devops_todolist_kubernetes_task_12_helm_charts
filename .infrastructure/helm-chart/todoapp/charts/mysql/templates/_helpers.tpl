{{- define "mysql.fullname" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "mysql.secretName" -}}
{{- printf "%s-%s" .Chart.Name .Values.secrets.name -}}
{{- end -}}

{{- define "mysql.configMapName" -}}
{{- .Chart.Name -}}
{{- end -}}

