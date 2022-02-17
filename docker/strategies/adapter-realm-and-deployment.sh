#!/bin/bash

REALM_CONFIG=principal-attribute="preferred_username",ssl-required=EXTERNAL,auth-server-url="${OLD_AUTH_SERVER}"
DEPLOYMENT_CONFIG=realm=keycloak,provider="keycloak",resource="${RESOURCE}"

# Note: If you actually run these in a single batch you may get ConcurrentAccessException...

/opt/jboss/wildfly/bin/jboss-cli.sh -c <<EOF
batch
/subsystem=keycloak/realm="keycloak"/:add(${REALM_CONFIG})
run-batch
EOF

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
