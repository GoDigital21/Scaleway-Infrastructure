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

resource "scaleway_instance_ip" "ip" {}

resource "scaleway_instance_server" "docker" {
  type = "DEV1-S"
  image = "docker"
  name  = "docker-server"

  tags = [ "docker", "mainserver" ]

  ip_id = scaleway_instance_ip.ip.id

  connection {
    type        = "ssh"
    user        = "root"
    private_key = tls_private_key.sshkey.private_key_pem
    host        = scaleway_instance_ip.public_ip.address
  }
}

resource "github_actions_organization_secret" "private_key_instance" {
  visibility      = "all"
  secret_name     = "INSTANCE_SSH"
  plaintext_value  = tls_private_key.sshkey.private_key_openssh
}

resource "github_actions_organization_secret" "ip_instance" {
  visibility      = "all"
  secret_name      = "INSTANCE_IP"
  plaintext_value  = scaleway_instance_ip.public_ip.address
}
