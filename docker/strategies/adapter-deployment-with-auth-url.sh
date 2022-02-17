#!/bin/bash

DEPLOYMENT_CONFIG=principal-attribute="preferred_username",ssl-required=EXTERNAL,resource="${RESOURCE}",realm="keycloak",auth-server-url="${OLD_AUTH_SERVER}"

# Note: If you actually run these in a single batch you may get ConcurrentAccessException...

/opt/jboss/wildfly/bin/jboss-cli.sh -c <<EOF
batch
/subsystem=keycloak/secure-deployment="${WAR}"/:add(${DEPLOYMENT_CONFIG})
run-batch
EOF

/opt/jboss/wildfly/bin/jboss-cli.sh -c <<EOF
batch
/subsystem=keycloak/secure-deployment="${WAR}"/credential=secret:add(value="${SECRET}")
run-batch
EOF
