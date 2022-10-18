terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

provider "scaleway" {
  access_key      = "<SCW_ACCESS_KEY>"
  secret_key      = "<SCW_SECRET_KEY>"
  project_id      = "<SCW_DEFAULT_PROJECT_ID>"
  zone       = "fr-par-1"
  region     = "fr-par"
}

#--------- create database --------------

# create relational database with root user 
resource "scaleway_rdb_instance" "main" {
  name              = "main"
  node_type         = "db-dev-s"
  volume_type       = "bssd"
  engine            = "PostgreSQL-14"
  is_ha_cluster     = true
  disable_backup    = false
  volume_size_in_gb = "10"
  user_name         = "root"
  password          = var.rdb_user_root_password
  tags = [ "terraform instance", "my-instance" ]
}

# creates database inside the main database
resource "scaleway_rdb_database" "test-rdb" {
  instance_id = scaleway_rdb_instance.main.id
  name        = "test-db"
}

# create user for database
resource "scaleway_rdb_user" "test-rdb-user" {
  instance_id = scaleway_rdb_instance.main.id
  name        = "test"
  password    = var.rdb_user_scaleway_db_password
  is_admin    = false
}

#--------- create database --------------
