#!/bin/bash

WAR="app.war"
AUTH_SERVER="http://keycloak:8080/auth"
REALM="test-realm"
SECRET="1sLzvauxRvpSP0cqt0Ijo9EFux1NsEuZ"
RESOURCE="app"

/opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 &

sleep 4

if [[ "${USE_OLD_ADAPTER}" == "true" ]]; then

echo "Using Old Keycloak Client Adapter"

cd /opt/jboss/wildfly
wget https://github.com/keycloak/keycloak/releases/download/17.0.0/keycloak-oidc-wildfly-adapter-17.0.0.zip
unzip keycloak-wildfly-adapter-dist-17.0.0.zip
/opt/jboss/wildfly/bin/jboss-cli.sh --file=bin/adapter-elytron-install-offline.cli

/opt/jboss/wildfly/bin/jboss-cli.sh -c <<EOF
batch
/subsystem=keycloak/secure-deployment="${WAR}"/:add( \
    realm="${REALM}", \
    principal-attribute="preferred_username" , \
    resource="${RESOURCE}", \
    auth-server-url=${AUTH_SERVER}, \
    ssl-required=EXTERNAL)
/subsystem=keycloak/secure-deployment="${WAR}"/credential=secret:add(value="${SECRET}")
run-batch
EOF

else

echo "Using New Build-in OIDC"

/opt/jboss/wildfly/bin/jboss-cli.sh -c <<EOF
batch
/subsystem=elytron-oidc-client/secure-deployment="${WAR}"/:add( \
           realm="${REALM}", \
           principal-attribute="preferred_username" , \
           resource="${RESOURCE}", \
           auth-server-url="${AUTH_SERVER}", \
           ssl-required=EXTERNAL)
/subsystem=elytron-oidc-client/secure-deployment="${WAR}"/credential=secret:add(secret="${SECRET}")
run-batch
EOF

fi

cp /app.war /opt/jboss/wildfly/standalone/deployments

sleep infinity