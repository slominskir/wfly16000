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
gradlw build
```
3. Launch Docker Compose test environment
```
docker compose up
```
4. Navigate browser to app and login

[localhost:8080/app](localhost:8080/app)

 - **User**: `user`
 - **Pass**: `user`

5. Now try doing a redeploy and watch log for error

```
docker exec -it wildfly cp /app.war /opt/jboss/wildfly/standalone/deployments
```

## Notes

 1. The login (step 4) actually doesn't work, due to a `ERROR [org.wildfly.security.http.oidc] (default task-1) ELY23013: Failed verification of token: ELY23019: Invalid ID token`.  This likely is due to backend path to Keycloak (keycloak:8080) differing from front-end path (localhost:8081).  If you install and run Wildfly directly on the host machine and replace provider-url with "localhost:8081", the login does work.   I'm looking into this, but the test case does still show that redeploys break the Wildfly auth config. 
 1. A custom entrypoint is used to copy standalone.xml into place as opposed to bind mounting directly since Wildfly writes to standalone.xml at runtime.
