#!/bin/bash

DEPLOYMENT_CONFIG=principal-attribute="preferred_username",ssl-required=EXTERNAL,resource="${RESOURCE}",provider-url="${PROVIDER_URL}"

/opt/jboss/wildfly/bin/jboss-cli.sh -c <<EOF
batch
/subsystem=elytron-oidc-client/secure-deployment="${WAR}"/:add(${DEPLOYMENT_CONFIG})
/subsystem=elytron-oidc-client/secure-deployment="${WAR}"/credential=secret:add(secret="${SECRET}")
run-batch
EOF
