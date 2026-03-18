{{- define "todoapp.fullname" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "todoapp.serviceAccountName" -}}
{{- printf "%s-%s" .Chart.Name .Values.serviceAccount.name -}}
{{- end -}}

{{- define "todoapp.secretName" -}}
{{- printf "%s-%s" .Chart.Name .Values.secrets.name -}}
{{- end -}}

{{- define "todoapp.configMapName" -}}
{{- printf "%s-%s" .Chart.Name .Values.configMap.name -}}
{{- end -}}

{{- define "todoapp.pvName" -}}
{{- printf "%s-pv-data" .Chart.Name -}}
{{- end -}}

{{- define "todoapp.pvcName" -}}
{{- printf "%s-pvc-data" .Chart.Name -}}
{{- end -}}

