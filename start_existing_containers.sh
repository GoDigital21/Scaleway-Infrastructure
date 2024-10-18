#iterate through every folder in data/containers and run docker-compose up -d if a docker-compose.yml file exists
for d in /data/containers/*/ ; do
    if [ -f "$d/docker-compose.yml" ]; then
        echo "starting $d"
        docker compose -f "$d/docker-compose.yml" up -d
    fi
done
echo "Successfully started all existing containers"