#!/bin/bash

WAR="app.war"
REALM="test-realm"
SECRET="1sLzvauxRvpSP0cqt0Ijo9EFux1NsEuZ"
RESOURCE="app"
PROVIDER_URL="http://keycloak:8080/auth/realms/test-realm"
AUTH_SERVER="http://keycloak:8080/auth"
OLD_AUTH_SERVER="http://keycloak:8080"


if [[ "${INSTALL_OLD_ADAPTER}" == "true" ]]; then
cd /opt/jboss/wildfly
curl -L https://github.com/keycloak/keycloak/releases/download/17.0.0/keycloak-oidc-wildfly-adapter-17.0.0.zip -o keycloak-oidc-wildfly-adapter-17.0.0.zip
unzip keycloak-oidc-wildfly-adapter-17.0.0.zip
/opt/jboss/wildfly/bin/jboss-cli.sh --file=bin/adapter-elytron-install-offline.cli
fi


/opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 &

sleep 4

STRATEGY_FILE=${STRATEGY_FILE:-'oidc-provider-and-deployment.sh'}
echo "Using Configuration Strategy File: ${STRATEGY_FILE}"

. /strategies/${STRATEGY_FILE}

cp /app.war /opt/jboss/wildfly/standalone/deployments

sleep infinity