{{- define "todoapp.serviceAccountName" -}}
{{ .Chart.Name }}-{{ .Values.serviceAccount.name }}
{{- end }}
{{- define "todoapp.namespace" -}}
{{ .Chart.Name }}-{{ .Values.todoapp.namespace }}
{{- end }}
