docker network create proxy

#create /data/letsencrypt if it doesn't exist
if [ -d /data/letsencrypt ]; then
    echo "/data/letsencrypt already exists"
else
    echo "creating /data/letsencrypt"
    mkdir /data/letsencrypt
fi

mkdir /traefik

mv /tmp/traefik-compose.yml /traefik/docker-compose.yml

cd /traefik

docker compose up -d

echo "Successfully started Traefik"