terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
    github = {
      source  = "integrations/github"
    }
  }
  required_version = ">= 0.13"
}

provider "github" {
  token = var.github_token # or `GITHUB_TOKEN`
  owner = "GoDigital21"
}

provider "scaleway" {
  #access_key      = SCW_ACCESS_KEY
  #secret_key      = "<SCW_SECRET_KEY>"
  #project_id      = "<SCW_DEFAULT_PROJECT_ID>"
  zone       = "fr-par-1"
  region     = "fr-par"
}

#--------- create database --------------

# create relational database with root user 
#resource "scaleway_rdb_instance" "main" {
#  name              = "main"
#  node_type         = "db-dev-s"
#  volume_type       = "bssd"
#  engine            = "PostgreSQL-14"
#  is_ha_cluster     = false
#  disable_backup    = false
#  volume_size_in_gb = "5"
#  user_name         = "root"
#  password          = var.rdb_user_root_password
#  tags = [ "terraform instance", "my-instance" ]
#}

# creates database inside the main database
#resource "scaleway_rdb_database" "test-rdb" {
#  instance_id = scaleway_rdb_instance.main.id
#  name        = "test-db"
#}

# create user for database
#resource "scaleway_rdb_user" "test-rdb-user" {
#  instance_id = scaleway_rdb_instance.main.id
#  name        = "test"
#  password    = var.rdb_user_scaleway_db_password
#  is_admin    = false
#}

#--------- create database --------------


#--------- create Instance --------------
#generate sshkey
resource "tls_private_key" "sshkey" {
  algorithm = "ED25519"
}

resource "scaleway_account_ssh_key" "main" {
  name       = "main"
  public_key = tls_private_key.sshkey.public_key_openssh
}

resource "scaleway_instance_ip" "public_ip" {}

resource "scaleway_instance_volume" "docker_data" {
    type       = "b_ssd"
    name       = "docker-data-volume"
    size_in_gb = 50
    tags= ["docker-data"]
}

resource "scaleway_instance_server" "docker" {
  type = "DEV1-S"
  image = "docker"
  name  = "docker-server"

  tags = [ "docker", "mainserver" ]

  ip_id = scaleway_instance_ip.public_ip.id

  connection {
    type        = "ssh"
    user        = "root"
    private_key = tls_private_key.sshkey.private_key_pem
    host        = scaleway_instance_ip.public_ip.address
  }

  root_volume {
    size_in_gb = 10
  }

  additional_volume_ids = [ scaleway_instance_volume.docker_data.id ]

  provisioner "file" {
    source      = "format.sh"
    destination = "/tmp/format.sh"
  }

  provisioner "file" {
    source      = "configure_docker.sh"
    destination = "/tmp/configure_docker.sh"
  }

  provisioner "file" {
    source      = "daemon.json"
    destination = "/tmp/daemon.json"
  }

  provisioner "file" {
    source      = "traefik-compose.yml"
    destination = "/tmp/traefik-compose.yml"
  }

  provisioner "file" {
    source      = "install_traefik.sh"
    destination = "/tmp/install_traefik.sh"
  }

  provisioner "file" {
    source      = "start_existing_containers.sh"
    destination = "/tmp/start_existing_containers.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/format.sh",
      "/tmp/format.sh args",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/configure_docker.sh",
      "/tmp/configure_docker.sh args",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_traefik.sh",
      "/tmp/install_traefik.sh args",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/start_existing_containers.sh",
      "/tmp/start_existing_containers.sh args",
    ]
  }
}

resource "github_actions_organization_secret" "private_key_instance" {
  visibility      = "all"
  secret_name     = "DOCKER_INSTANCE_IP"
  plaintext_value  = tls_private_key.sshkey.private_key_openssh
}

resource "github_actions_organization_secret" "ip_instance" {
  visibility      = "all"
  secret_name      = "DOCKER_INSTANCE_IP"
  plaintext_value  = scaleway_instance_ip.public_ip.address
}
