#move docker data location to /data/docker

sudo systemctl stop docker

#check if data/docker exists
#if [ ! -d /data/docker ]; then
#  echo "creating /data/docker"
#  mkdir -p /data/docker
#  sudo rsync -aP /var/lib/docker/ /data/docker
#fi

#sudo mv /tmp/daemon.json /etc/docker/daemon.json

#sudo systemctl daemon-reload
#sudo systemctl restart docker

sudo apt-get update
sudo apt-get install docker-compose-plugin
