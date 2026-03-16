{{- define "mysql.namespace" -}}
{{- printf "%s-%s" .Chart.Name .Values.namespace.name -}}
{{- end -}}

{{- define "mysql.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "mysql.secretName" -}}
{{- printf "%s-secrets" .Chart.Name -}}
{{- end -}}

{{- define "mysql.configMapName" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "mysql.pvcName" -}}
{{- printf "%s-data" .Chart.Name -}}
{{- end -}}

{{- define "mysql.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
