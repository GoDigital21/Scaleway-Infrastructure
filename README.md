# Infrastructure as Code: Setup Docker with Traefik

This repository contains the code to setup a Docker environment with Traefik as a reverse proxy.
It makes sure that all data is stored on a separate volume and that the Docker daemon is configured to use this volume.
Further it installs traefik and configures it to use letsencrypt for SSL certificates and redirects all traffic to HTTPS.

Everything is configured in a way that the machine can be easily destroyed and recreated without losing any data. Further it will also automatically start all containers that were running before the machine was destroyed.

To manage the states, terraform cloud is used.
## Notes:

https://www.scaleway.com/en/docs/tutorials/terraform-quickstart/


Explanation:
first:
  #access_key      = "<SCW_ACCESS_KEY>"
  #secret_key      = "<SCW_SECRET_KEY>"
  #project_id      = "<SCW_DEFAULT_PROJECT_ID>"
need to be set at terrform cloud

once to be formated: mkfs.ext4 /dev/sda
mount it: mount -o defaults /dev/sdb /data


gets automatically triggered on push to main!
check https://app.terraform.io/app/godigital21/workspaces/Scaleway-Infrastructure


easy treafik setup:
https://medium.com/@rossinigiovanni/traefik-how-to-proxy-with-lets-encrypt-nginx-or-docker-a98f6d79626c