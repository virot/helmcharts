{{- define "versitygw.name" -}}
versitygw
{{- end }}

{{- define "versitygw.fullname" -}}
{{ include "versitygw.name" . }}-{{ .Release.Name }}
{{- end }}

{{- define "versitygw.secretKey" -}}
{{- if .Values.env.ROOT_SECRET_KEY -}}
{{ .Values.env.ROOT_SECRET_KEY }}
{{- else -}}
{{ randAlphaNum 32 }}
{{- end -}}
{{- end }}
