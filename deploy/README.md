# Deploy steps

1. Build release on a machine that isn't the target
```
sudo docker build --build-arg APP_NAME=$APP_NAME --build-arg DATABASE_URL=$DATABASE_URL --build-arg SECRET_KEY_BASE=$SECRET_KEY_BASE --build-arg PHX_HOST=$PHX_HOST -t collaborlist:v1 ../
```

2. Save docker image that was just built
```
sudo docker save -o collaborlist.tar collaborlist:v1
```

3. Copy the docker image to target machine

4. `docker compose up -d`

to get ssl certs initially, the nginx server would have to be started first, then the certbot afterwards

Also, ensure that the DNS is allowing http traffic through for initial certs (cloudflare uncheck proxy). After valid certs are acquired from CA, it can be switched to only https.

