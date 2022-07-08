{{- define "pipelineruntemplate" -}}
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  {{- include "react.pipelineRunName" . | nindent 2}}
  labels:
    {{- include "t.labels" . | nindent 4 }}
    tekton.dev/pipeline: {{ .Release.Name }}
  annotations:
    argocd.argoproj.io/compare-options: IgnoreExtraneous
spec:
  pipelineRef:
    name: {{ .Release.Name }}
  timeout: {{ .Values.global.pipeline.timeout }}
  {{- if .Values.global.git.ssh.privatekey.sealed }}
  serviceAccountName: pipeline-{{ .Release.Name }}
  {{- else }}
  serviceAccountName: pipeline
  {{- end }}
  workspaces:
    - name: source
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: {{ .Values.global.pipeline.source.storage.size }}
        status: {}
    - name: dockerfile
      configMap:
        name: ruby-dockerfile
    - configMap:
        name: react-build-context
      name: build-configuration-files
    {{- if .Values.global.pipeline.sonarqube.enabled }}
    - name: sonar-settings
      configMap:
        name: sonar-project-properties
    {{- end }}
    {{- if .Values.global.pipeline.qtest.enabled }}
    - name: qtest-settings
      configMap:
        name: qtest-settings
    {{- end}}
  params:
    - name: gitUrl
      value: {{ .Values.global.git.url }}
    - name: gitRevision
      value: {{ .Values.global.git.revision }}
    - name: context
      value: {{ .Values.global.git.context }}
    - name: image
      value: {{ .Values.global.image.registry }}/{{ .Values.global.image.name | default .Release.Name }}
    - name: imageTag
      value: {{ regexReplaceAll "\\/" (default .Values.global.git.revision .Values.global.image.tag) "-" }}
    - name: appName
      value: {{ .Release.Name }}
    {{- if .Values.global.release.enabled }}
    - name: serviceNowURL
      value: {{ .Values.global.release.serviceNowURL }}
    - name: changeRequest
      value: {{ .Values.global.release.changeRequest }}
    {{- end }}
    {{- if .Values.global.pipeline.checkmarx.enabled }}
    - name: checkmarxTeamName
      value: {{ .Values.global.pipeline.checkmarx.teamName }}
    {{- end }}
    - name: keepCount
      value: {{ .Values.global.pipeline.keepCount | quote }}
    - name: yarn-build-command
      value: {{ .Values.global.pipeline.build.yarnCommand}}
    - name: yarn-test-command
      value: {{ .Values.global.pipeline.unitTests.command}}
    - name: nodeVersion
      value: {{ .Values.nodeVersion | quote }}
    {{- if .Values.global.pipeline.nexusIQ.enabled }}
    - name: scanLocation
      value: {{ .Values.global.pipeline.nexusIQ.scanLocation }}
    - name: nexusIQTeamName
      value: {{ .Values.global.pipeline.nexusIQ.teamName }}
    {{- end }}
    {{- if .Values.global.pipeline.sonarqube.enabled }}
    - name: sonarProjectKey
      value: {{ .Values.global.teamName }}-{{ .Release.Name }}
    - name: sonarSources
      value: {{ .Values.global.pipeline.sonarqube.sources | quote }}
    - name: sonarTests
      value: {{ .Values.global.pipeline.sonarqube.tests | quote }}
    - name: sonarExclusions
      value: {{ .Values.global.pipeline.sonarqube.exclusions | quote | default "none" }}
    {{- end }}
    {{- if .Values.global.pipeline.dockerfile.enabled }}
    - name: dockerfile
      value: {{ .Values.global.pipeline.dockerfile.location }}
    {{- end }}
    {{- if .Values.global.nginx.context.enabled }}
    - name: buildArgs
      value: "--build-arg CONTEXT_PATH={{ .Values.global.nginx.context.path | default .Release.Name }}"
    {{- end }}
    - name: agileTeamName
      value: {{ .Values.global.agileTeamName }}
    - name: teamName
      value: {{ .Values.global.teamName }}
    - name: businessGroup
      value: {{ .Values.global.businessGroup }}
    {{- if .Values.global.pipeline.wdio.enabled }}
    - name: wdio-command
      value: {{ .Values.global.pipeline.wdio.command }}
    {{- end }}
    - name: headless-wdio
      value: {{ .Values.global.pipeline.wdio.headless | quote}}
    {{- if .Values.global.pipeline.notifications.enabled }}
    - name: teamsChannel
      value: {{ .Values.global.pipeline.notifications.teamsChannel }}
    {{- end }}
    - name: cluster
      value: {{ .Values.global.cluster }}
    - name: technology
      value: {{ include "applicationType" . | quote }}
    - name: helmChartName
      value: {{ .Chart.Name }}
    - name: helmChartVersion
      value: {{ .Chart.Version }}
    - name: releaseEnvironment
      value: {{ .Values.global.release.enabled | quote }}
    {{- if .Values.global.release.enabled }}
    - name: gitUserName
      value: {{ .Values.global.pipeline.gitUserName | default "none" }}
    - name: gitUserEmail
      value: {{ .Values.global.pipeline.gitUserEmail | default "none" }}
    {{- end }}
{{- end }}
