# wfly16000

Test case demonstrating Wildfly Issue [WFLY-16000](https://issues.redhat.com/browse/WFLY-16000).

## Usage
1. Grab project
```
git clone https://github.com/slominskir/wfly16000
cd wfly16000
```
2. Build test app.war
```
gradlew build
```
3. Launch Docker Compose test environment
```
docker compose up
```
4. Navigate browser to app and login

[http://localhost:8080/app](http://localhost:8080/app)

 - **User**: `user`
 - **Pass**: `user`

5. Now try doing a redeploy and watch log for error

```
docker exec -it wildfly cp /app.war /opt/jboss/wildfly/standalone/deployments
```

## Notes

The login fails with `ERROR [org.wildfly.security.http.oidc] (default task-1) ELY23013: Failed verification of token: ELY23019: Invalid ID token`.  This appears to be a separate issue, and does not prevent observing the redploy issue.  See workaround below, which actually corrects both the redeploy issue and this Invalid ID token issue.

The redeploy issue only occurs when using `provider-url` in a `provider` config element (with a separate `secure-deployment` element).   The `provider` configuration is best suited for when you have multiple apps sharing the same security provider.  The alternative is to define an `auth-server-url` directly in the secure-deployment config.  This `auth-server-url` configuration works - to see it working:

1. Stop the compose environment and clean it up:
```
docker compose down
```
2. Set environment variable STRATEGY_FILE=`oidc-deployment-with-auth-url.sh`:

Windows CMD
```
set STRATEGY_FILE=oidc-deployment-with-auth-url.sh
```
Linux Bash
```
export STRATEGY_FILE=oidc-deployment-with-auth-url.sh
```
3. Run through the Usage steps above again, starting with step 3: `docker-compose up`



## Workaround

This `provider-url` configuration does not survive redeploy (and should):
```
        <subsystem xmlns="urn:wildfly:elytron-oidc-client:1.0">
            <provider name="keycloak">
                <provider-url>http://keycloak:8080/auth/realms/test-realm</provider-url>
                <ssl-required>none</ssl-required>
                <principal-attribute>preferred_username</principal-attribute>
            </provider>
            <secure-deployment name="app.war">
                <provider>keycloak</provider>
                <client-id>app</client-id>
                <credential name="secret" secret="1sLzvauxRvpSP0cqt0Ijo9EFux1NsEuZ"/>
            </secure-deployment>
        </subsystem>
```

This `auth-server-url` does survive redeploy:
```
        <subsystem xmlns="urn:wildfly:elytron-oidc-client:1.0">
            <secure-deployment name="app.war">
                <auth-server-url>http://keycloak:8080/auth</auth-server-url>
                <realm>test-realm</realm>
                <ssl-required>none</ssl-required>
                <principal-attribute>preferred_username</principal-attribute>
                <client-id>app</client-id>
                <credential name="secret" secret="1sLzvauxRvpSP0cqt0Ijo9EFux1NsEuZ"/>
            </secure-deployment>
        </subsystem>
```

## Things that don't work
### Old adapter
Worth pointing out that using the old adapter with latest Keycloak (26.0.1) doesn't appear to be an option - it doesn't seem to work.  Set environment variables STRATEGY_FILE=`adapter-deployment-with-auth-url.sh` and INSTALL_OLD_ADAPTER=`true` and see what I mean.   You'll proably want to edit the web.xml and replace `OIDC` with `KEYCLOAK`.  Still doesn't work though.  

### provider-url inside secure-deployment element
You can actually use the `provider-url` inside a `secure-deployment` element of standalone.xml (as opposed to inside a `provider` element).  This does sidestep the redeploy issue, but does NOT avoid the Invalid ID Token issue.
