terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Netzwerk
resource "docker_network" "local_network" {
  name = var.network_name
}

# Volume für Postgres
resource "docker_volume" "pg_data" {
  name = var.volume_name
}

# Images
resource "docker_image" "postgres" {
  name = "postgres:15"
}

resource "docker_image" "adminer" {
  name = "adminer:latest"
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

# PostgreSQL Container
resource "docker_container" "postgres" {
  name  = "local-postgres"
  image = docker_image.postgres.image_id

  networks_advanced {
    name = docker_network.local_network.name
  }

  env = [
    "POSTGRES_DB=${var.db_name}",
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}"
  ]

  ports {
    internal = 5432
    external = var.db_port
  }

  volumes {
    volume_name    = docker_volume.pg_data.name
    container_path = "/var/lib/postgresql/data"
  }
}

# Adminer Container
resource "docker_container" "adminer" {
  name  = "local-adminer"
  image = docker_image.adminer.image_id

  networks_advanced {
    name = docker_network.local_network.name
  }


}

# nginx Reverse Proxy
resource "docker_container" "nginx" {
  name  = "local-nginx"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.local_network.name
  }

  ports {
    internal = 80
    external = var.proxy_port
  }

  mounts {
    type      = "bind"
    source    = "${abspath("${path.module}/nginx")}"
    target    = "/etc/nginx/conf.d"
    read_only = true
  }

  depends_on = [
    docker_container.adminer
  ]
}

output "nginx_proxy_url" {
  description = "URL für den nginx Reverse Proxy, der auf Adminer zeigt"
  value       = "http://localhost:${var.proxy_port}"
}

output "adminer_direct_url" {
  description = "Direkter Adminer-Zugang (ohne nginx, falls nötig)"
  value       = "http://localhost:${var.adminer_port}"
}

output "postgres_connection_info" {
  description = "PostgreSQL interne Connection Info (innerhalb Docker-Netzwerk)"
  value = {
    host     = "local-postgres"
    user     = var.db_user
    password = var.db_password
    db_name  = var.db_name
    port     = 5432
  }
}

