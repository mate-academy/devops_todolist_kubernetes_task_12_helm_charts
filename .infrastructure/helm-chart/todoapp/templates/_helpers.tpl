{{- define "todoapp.namespace" -}}
{{- $configured := .Values.common.namespace -}}
{{- if hasPrefix .Chart.Name $configured -}}
{{- $configured -}}
{{- else -}}
{{- printf "%s-%s" .Chart.Name $configured -}}
{{- end -}}
{{- end -}}
