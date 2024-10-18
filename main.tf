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
  zone       = "fr-par-2"
}

//make use of the repos.txt file
data "local_file" "repos" {
  filename = "${path.module}/repos.txt"
}

locals {
  repos = [
    for repo in split("\n", chomp(data.local_file.repos.content)) :
    element(split("/", repo), 1) if repo != "" && repo != "."
  ]
}

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

  provisioner "remote-exec" {
    inline = [
      "mkdir /maintenance",
    ]
  }

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
    source      = "clone_repos.sh"
    destination = "/maintenance/clone_repos.sh"
  }

  provisioner "file" {
    source      = "repos.txt"
    destination = "/maintenance/repos.txt"
  }

  provisioner "file" {
    source      = "start_existing_containers.sh"
    destination = "/maintenance/start_existing_containers.sh"
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
      "chmod +x /maintenance/clone_repos.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /maintenance/start_existing_containers.sh",
    ]
  }
}

resource "github_actions_organization_secret" "private_key_instance" {
  visibility      = "all"
  secret_name     = "DOCKER_INSTANCE_PRIVATE_KEY"
  plaintext_value  = tls_private_key.sshkey.private_key_openssh
}

resource "github_actions_organization_secret" "ip_instance" {
  visibility      = "all"
  secret_name      = "DOCKER_INSTANCE_IP"
  plaintext_value  = scaleway_instance_ip.public_ip.address
}

//SELF
resource "github_actions_secret" "private_key_instance_self" {
  repository       = "Scaleway-Infrastructure"
  secret_name      = "DOCKER_INSTANCE_PRIVATE_KEY"
  plaintext_value  = tls_private_key.sshkey.private_key_openssh
}

resource "github_actions_secret" "ip_instance_self" {
  repository       = "Scaleway-Infrastructure"
  secret_name      = "DOCKER_INSTANCE_IP"
  plaintext_value  = scaleway_instance_ip.public_ip.address
}

//---- ADD TO REPOS -----

resource "github_actions_secret" "ip_instance" {
  for_each         = toset(local.repos)
  repository       = each.key
  secret_name      = "DOCKER_INSTANCE_IP"
  plaintext_value  = scaleway_instance_ip.public_ip.address
}

resource "github_actions_secret" "private_key_instance" {
  for_each         = toset(local.repos)
  repository       = each.key
  secret_name      = "DOCKER_INSTANCE_PRIVATE_KEY"
  plaintext_value  = tls_private_key.sshkey.private_key_openssh
}