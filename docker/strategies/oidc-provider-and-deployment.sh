#!/bin/bash

PROVIDER_CONFIG=principal-attribute="preferred_username",ssl-required=EXTERNAL,provider-url="${PROVIDER_URL}"
DEPLOYMENT_CONFIG=provider="keycloak",resource="${RESOURCE}"

/opt/jboss/wildfly/bin/jboss-cli.sh -c <<EOF
batch
/subsystem=elytron-oidc-client/provider="keycloak"/:add(${PROVIDER_CONFIG})
/subsystem=elytron-oidc-client/secure-deployment="${WAR}"/:add(${DEPLOYMENT_CONFIG})
/subsystem=elytron-oidc-client/secure-deployment="${WAR}"/credential=secret:add(secret="${SECRET}")
run-batch
EOF


