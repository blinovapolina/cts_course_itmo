{{- define "portal.secretsData" -}}
JWT_PRIVATE_KEY: {{ .Values.configs.secret.jwt_private_key | b64enc | quote }}
JWT_PUBLIC_KEY: {{ .Values.configs.secret.jwt_public_key | b64enc | quote }}
SECRET_KEY: {{ .Values.configs.secret.secret_key | b64enc | quote }}
{{- end -}}

{{- define "portal.secret.amqpHostString" -}}
{{- if .Values.rabbitmq.enabled }}
{{- if not (empty .Values.rabbitmq.auth.password) -}}
AMQP_HOST_STRING: {{ printf "amqp://%s:%s@%s:%d/%s" .Values.rabbitmq.auth.username .Values.rabbitmq.auth.password (include "rabbitmq.host" . ) (int .Values.rabbitmq.containerPorts.amqp) .Values.rabbitmq.auth.vhost | b64enc | quote }}
{{- else -}}
AMQP_HOST_STRING: {{ printf "amqp://%s:%s@%s:%d/%s" .Values.rabbitmq.auth.username (include "rabbitmq.exist.password") (include "rabbitmq.host" . ) (int .Values.rabbitmq.containerPorts.amqp) .Values.rabbitmq.auth.vhost | b64enc | quote }}
{{- end -}}
{{- else if .Values.externalRabbitmq.enabled }}
{{- if not (empty .Values.externalRabbitmq.password) -}}
AMQP_HOST_STRING: {{ printf "%s://%s:%s@%s:%d/%s" .Values.externalRabbitmq.scheme .Values.externalRabbitmq.username .Values.externalRabbitmq.password .Values.externalRabbitmq.host (int .Values.externalRabbitmq.port) .Values.externalRabbitmq.vhost | b64enc | quote }}
{{- else -}}
AMQP_HOST_STRING: {{ printf "%s://%s:%s@%s:%d/%s" .Values.externalRabbitmq.scheme .Values.externalRabbitmq.username (include "rabbitmq.external.exist.password" . ) .Values.externalRabbitmq.host (int .Values.externalRabbitmq.port) .Values.externalRabbitmq.vhost | b64enc | quote }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "portal.base_url" -}}
    {{- if not (empty .Values.ingress.host) }}
        {{- if not .Values.configs.configMap.cookies_secure -}}
            {{ printf "http://%s" .Values.ingress.host | quote }}    
        {{- end -}}
        {{- if .Values.configs.configMap.cookies_secure -}}
            {{ printf "https://%s" .Values.ingress.host | quote }}
        {{- end -}}
    {{- else if not (empty .Values.configs.configMap.domain) }}
        {{- if not .Values.configs.configMap.cookies_secure -}}
            {{ printf "http://%s" .Values.configs.configMap.domain | quote }}   
        {{- end -}}
        {{- if .Values.configs.configMap.cookies_secure -}}
            {{ printf "https://%s" .Values.configs.configMap.domain | quote }}   
        {{- end -}}
    {{- end }}
{{- end -}}

{{- define "getValueFromSecret" }}
{{- $len := (default 16 .Length) | int -}}
{{- $obj := (lookup "v1" "Secret" .Namespace .Name).data -}}
{{- index $obj .Key | trimAll "\"" | b64dec -}}
{{- end }}

{{- define "rabbitmq.exist.password" -}}
    {{- include "getValueFromSecret" (dict "Namespace" .Release.Namespace "Name" .Values.rabbitmq.auth.existingPasswordSecret "Length" 16 "Key" .Values.rabbitmq.auth.existingSecretPasswordKey)  -}}
{{- end -}}

{{- define "rabbitmq.external.exist.password" -}}
    {{- include "getValueFromSecret" (dict "Namespace" .Release.Namespace "Name" .Values.externalRabbitmq.existingPasswordSecret "Length" 16 "Key" .Values.externalRabbitmq.existingSecretPasswordKey)  -}}
{{- end }}

{{- define "rabbitmq.host"}}
{{- printf "%s-%s" .Release.Name .Values.rabbitmq.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}   

{{- define "postgres.host"}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-%s" .Release.Name .Values.postgresql.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if .Values.externalPostgresql.enabled }}
{{- .Values.externalPostgresql.host | quote }}
{{- end }}
{{- end }}

{{- define "postgres.port" }}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.containerPorts.postgresql | quote }}
{{- else if .Values.externalPostgresql.enabled }}
{{- .Values.externalPostgresql.port | quote }}
{{- end }}
{{- end }}

{{- define "postgres.database.name" }}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database| quote }}
{{- else if .Values.externalPostgresql.enabled }}
{{- .Values.externalPostgresql.database | quote }}
{{- end }}
{{- end }}

{{- define "postgres.user" }}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username | quote }}
{{- else if .Values.externalPostgresql.enabled }}
{{- .Values.externalPostgresql.username | quote }}
{{- end }}
{{- end }}


{{- define "portal.postgres.password" -}}
{{- if .Values.postgresql.enabled }}
{{- if (eq "" .Values.postgresql.auth.existingSecret )}}
DB_PASS: {{ .Values.postgresql.auth.password | b64enc | quote }}
{{- end }}
{{- else if .Values.externalPostgresql.enabled }}
{{- if (eq "" .Values.externalPostgresql.existingSecret )}}
DB_PASS: {{ .Values.externalPostgresql.password | b64enc | quote }}
{{- end }}
{{- end }}
{{- end -}}


{{/*
Create portal name
*/}}
{{- define "portal.fullname" -}}
{{- printf "%s-%s" (include "portal.fullname" .) .Values.portal.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of portal service account to use
*/}}
{{- define "portal.ServiceAccountName" -}}
{{- if .Values.portal.serviceAccount.create -}}
    {{ default (include "portal.fullname" .) .Values.portal.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.portal.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Create db-helper name
*/}}
{{- define "dbhelper.fullname" -}}
{{- printf "%s-%s" (include "portal.fullname" .) .Values.dbhelper.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of db-helper service account to use
*/}}
{{- define "dbhelper.ServiceAccountName" -}}
{{- if .Values.dbhelper.serviceAccount.create -}}
    {{ default (include "dbhelper.fullname" .) .Values.dbhelper.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.dbhelper.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create dojo-helper name
*/}}
{{- define "dojohelper.fullname" -}}
{{- printf "%s-%s" (include "portal.fullname" .) .Values.dojohelper.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of dojo-helper service account to use
*/}}
{{- define "dojohelper.ServiceAccountName" -}}
{{- if .Values.dojohelper.serviceAccount.create -}}
    {{ default (include "dojohelper.fullname" .) .Values.dojohelper.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.dojohelper.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create importer name
*/}}
{{- define "importer.fullname" -}}
{{- printf "%s-%s" (include "portal.fullname" .) .Values.importer.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of importer service account to use
*/}}
{{- define "importer.ServiceAccountName" -}}
{{- if .Values.importer.serviceAccount.create -}}
    {{ default (include "importer.fullname" .) .Values.importer.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.importer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create jira-helper name
*/}}
{{- define "jirahelper.fullname" -}}
{{- printf "%s-%s" (include "portal.fullname" .) .Values.jirahelper.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of jira-helper service account to use
*/}}
{{- define "jirahelper.ServiceAccountName" -}}
{{- if .Values.jirahelper.serviceAccount.create -}}
    {{ default (include "jirahelper.fullname" .) .Values.jirahelper.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.jirahelper.serviceAccount.name }}
{{- end -}}
{{- end -}}
