{{- define "todoapp.fullname" -}}
{{- printf "%s-%s" .Chart.Name .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "todoapp.serviceAccountName" -}}
{{- if .Values.serviceAccount.name }}
{{- .Values.serviceAccount.name }}
{{- else }}
{{- printf "%s-sa" .Chart.Name }}
{{- end -}}
{{- end -}}
