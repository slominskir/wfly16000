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

[http://localhost:8080/app](http://localhost:8080/app)

 - **User**: `user`
 - **Pass**: `user`

5. Now try doing a redeploy and watch log for error

```
docker exec -it wildfly cp /app.war /opt/jboss/wildfly/standalone/deployments
```

## Notes

The problem only occurs when using `provider-url`.   The `provider-url` configuration is best suited for when you have multiple apps sharing the same security provider.  The alternative is to define an `auth-server-url` directly in the secure-deployment config.  This `auth-server-url` configuration works - to see it working:

1. Stop the compose environment and clean it up:
```
docker compose down
```
2. Modify `docker-compose.yml`:
Replace the line that reads: `USE_PROVIDER_URL: "true"` with `USE_PROVIDER_URL: "false"`.
3. Run through the Usage steps above again, starting with step 3: `docker-compose up`

