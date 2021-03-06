{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

`SPDX-License-Identifier: Apache-2.0`

This file is considered to be modified by the TrueCharts Project.
*/}}

{{/*
This template serves as a blueprint for all Service objects that are created
within the common library.
*/}}
{{- define "common.classes.service" -}}
{{- $values := .Values.services.main -}}
{{- if hasKey . "ObjectValues" -}}
  {{- with .ObjectValues.service -}}
    {{- $values = . -}}
  {{- end -}}
{{ end -}}

{{- $serviceName := include "common.names.fullname" . -}}


{{- if hasKey $values "nameSuffix" -}}
  {{- $serviceName = printf "%v-%v" $serviceName $values.nameSuffix -}}
{{ end -}}
{{- $svcType := $values.type | default "" -}}

{{- $portProtocol := $values.port.protocol -}}
{{- if or ( eq $values.port.protocol "HTTP" ) ( eq $values.port.protocol "HTTPS" ) ( eq $values.port.protocol "TCP" ) -}}
{{- $portProtocol = "TCP" -}}
{{- else if eq $values.port.protocol "UDP" }}
{{- $portProtocol = "UDP" -}}
{{- end }}
apiVersion: v1
kind: Service
metadata:
  name: {{ $serviceName }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- if $values.labels }}
    {{ toYaml $values.labels | nindent 4 }}
  {{- end }}
  annotations:
  {{- if eq $values.port.protocol "HTTPS" }}
    traefik.ingress.kubernetes.io/service.serversscheme: https
  {{- end }}
  {{- with $values.annotations }}
    {{ toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if (or (eq $svcType "ClusterIP") (empty $svcType)) }}
  type: ClusterIP
  {{- if $values.clusterIP }}
  clusterIP: {{ $values.clusterIP }}
  {{end}}
  {{- else if eq $svcType "LoadBalancer" }}
  type: {{ $svcType }}
  {{- if $values.loadBalancerIP }}
  loadBalancerIP: {{ $values.loadBalancerIP }}
  {{- end }}
  {{- if $values.externalTrafficPolicy }}
  externalTrafficPolicy: {{ $values.externalTrafficPolicy }}
  {{- end }}
  {{- if $values.loadBalancerSourceRanges }}
  loadBalancerSourceRanges:
    {{ toYaml $values.loadBalancerSourceRanges | nindent 4 }}
  {{- end -}}
  {{- else }}
  type: {{ $svcType }}
  {{- end }}
  {{- if $values.sessionAffinity }}
  sessionAffinity: {{ $values.sessionAffinity }}
  {{- if $values.sessionAffinityConfig }}
  sessionAffinityConfig:
    {{ toYaml $values.sessionAffinityConfig | nindent 4 }}
  {{- end -}}
  {{- end }}
  {{- with $values.externalIPs }}
  externalIPs:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if $values.publishNotReadyAddresses }}
  publishNotReadyAddresses: {{ $values.publishNotReadyAddresses }}
  {{- end }}
  {{- include "common.classes.service.ports" (dict "svcType" $svcType "values" $values ) | trim | nindent 2 }}
  selector:
    {{- include "common.labels.selectorLabels" . | nindent 4 }}
{{- end }}
