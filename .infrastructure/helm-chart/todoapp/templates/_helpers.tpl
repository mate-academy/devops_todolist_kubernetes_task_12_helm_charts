{{- define "todoapp.namespace" -}}
{{- printf "%s-%s" .Chart.Name .Values.namespace.name -}}
{{- end -}}

{{- define "todoapp.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "todoapp.serviceAccountName" -}}
{{- printf "%s-%s" .Chart.Name .Values.serviceAccount.name -}}
{{- end -}}

{{- define "todoapp.secretName" -}}
{{- printf "%s-secret" .Chart.Name -}}
{{- end -}}

{{- define "todoapp.configMapName" -}}
{{- printf "%s-config" .Chart.Name -}}
{{- end -}}

{{- define "todoapp.serviceName" -}}
{{- printf "%s-service" .Chart.Name -}}
{{- end -}}

{{- define "todoapp.pvName" -}}
{{- printf "%s-pv" .Chart.Name -}}
{{- end -}}

{{- define "todoapp.pvcName" -}}
{{- printf "%s-pvc" .Chart.Name -}}
{{- end -}}

{{- define "todoapp.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
