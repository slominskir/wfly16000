#!/bin/bash

WAR="app.war"
AUTH_SERVER="http://keycloak:8080/auth"
OLD_AUTH_SERVER="http://keycloak:8080"
REALM="test-realm"
PROVIDER_URL="http://keycloak:8080/auth/realms/test-realm"
SECRET="1sLzvauxRvpSP0cqt0Ijo9EFux1NsEuZ"
RESOURCE="app"

if [[ "${USE_OLD_ADAPTER}" == "true" ]]; then
cd /opt/jboss/wildfly
curl -L https://github.com/keycloak/keycloak/releases/download/17.0.0/keycloak-oidc-wildfly-adapter-17.0.0.zip -o keycloak-oidc-wildfly-adapter-17.0.0.zip
unzip keycloak-oidc-wildfly-adapter-17.0.0.zip
/opt/jboss/wildfly/bin/jboss-cli.sh --file=bin/adapter-elytron-install-offline.cli
fi

/opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 &
sleep 4

if [[ "${USE_OLD_ADAPTER}" == "true" ]]; then
echo "Using Old Keycloak Client Adapter"

if [[ "${USE_PROVIDER_URL}" == "true" ]]; then
REALM_CONFIG=principal-attribute="preferred_username",ssl-required=EXTERNAL,auth-server-url="${OLD_AUTH_SERVER}"
DEPLOYMENT_CONFIG=realm=keycloak,provider="keycloak",resource="${RESOURCE}"
/opt/jboss/wildfly/bin/jboss-cli.sh -c <<EOF
batch
/subsystem=keycloak/realm="keycloak"/:add(${REALM_CONFIG})
run-batch
EOF

else
DEPLOYMENT_CONFIG=principal-attribute="preferred_username",ssl-required=EXTERNAL,resource="${RESOURCE}",realm="keycloak",auth-server-url="${OLD_AUTH_SERVER}"
fi

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

else

echo "Using New Build-in OIDC"
if [[ "${USE_PROVIDER_URL}" == "true" ]]; then

PROVIDER_CONFIG=principal-attribute="preferred_username",ssl-required=EXTERNAL,provider-url="${PROVIDER_URL}"
DEPLOYMENT_CONFIG=provider="keycloak",resource="${RESOURCE}"

/opt/jboss/wildfly/bin/jboss-cli.sh -c <<EOF
batch
/subsystem=elytron-oidc-client/provider="keycloak"/:add(${PROVIDER_CONFIG})
run-batch
EOF

else
DEPLOYMENT_CONFIG=principal-attribute="preferred_username",ssl-required=EXTERNAL,resource="${RESOURCE}",realm="${REALM}",auth-server-url="${AUTH_SERVER}"
fi

/opt/jboss/wildfly/bin/jboss-cli.sh -c <<EOF
batch
/subsystem=elytron-oidc-client/secure-deployment="${WAR}"/:add(${DEPLOYMENT_CONFIG})
/subsystem=elytron-oidc-client/secure-deployment="${WAR}"/credential=secret:add(secret="${SECRET}")
run-batch
EOF

fi

cp /app.war /opt/jboss/wildfly/standalone/deployments

sleep infinity