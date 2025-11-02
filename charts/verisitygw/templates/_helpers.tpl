{{- define "versitygw.name" -}}
versitygw
{{- end }}

{{- define "versitygw.fullname" -}}
{{ include "versitygw.name" . }}-{{ .Release.Name }}
{{- end }}
