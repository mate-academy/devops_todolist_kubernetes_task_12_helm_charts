{{- define "mysql.namespace" -}}
{{- $configured := .Values.namespace -}}
{{- if hasPrefix .Chart.Name $configured -}}
{{- $configured -}}
{{- else -}}
{{- printf "%s-%s" .Chart.Name $configured -}}
{{- end -}}
{{- end -}}
