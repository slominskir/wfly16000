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

