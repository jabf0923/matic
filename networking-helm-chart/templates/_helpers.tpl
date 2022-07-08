{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "networking.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "networking.labels" -}}
helm.sh/chart: {{ include "networking.chart" . }}
{{ include "networking.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "networking.selectorLabels" -}}
app: {{ .Release.Name }}
app.kubernetes.io/name: {{ .Release.Name }}
{{- end }}
