# ---------- Secreto generado por Terraform ----------
resource "random_password" "db" {
  length  = 24
  special = false
}

# ---------- Red y volúmenes ----------
resource "docker_network" "net" {
  name = "${var.project}-net"
}

resource "docker_volume" "pgdata" {
  name = "${var.project}-pgdata"

  lifecycle {
    prevent_destroy = true
  }
}

# ---------- Imágenes ----------
resource "docker_image" "postgres" {
  name         = "postgres:16-alpine"
  keep_locally = true
}

resource "docker_image" "redis" {
  name         = "redis:7-alpine"
  keep_locally = true
}

# ---------- Postgres ----------
resource "docker_container" "db" {
  name    = "${var.project}-db"
  image   = docker_image.postgres.image_id
  restart = "unless-stopped"

  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${random_password.db.result}",
    "POSTGRES_DB=${var.db_name}",
  ]

  networks_advanced {
    name    = docker_network.net.name
    aliases = ["db"]
  }

  volumes {
    volume_name    = docker_volume.pgdata.name
    container_path = "/var/lib/postgresql/data"
  }

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U ${var.db_user} -d ${var.db_name}"]
    interval = "5s"
    timeout  = "3s"
    retries  = 5
  }

  wait         = true
  wait_timeout = 60
}

# ---------- Redis ----------
resource "docker_container" "redis" {
  name    = "${var.project}-redis"
  image   = docker_image.redis.image_id
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.net.name
    aliases = ["redis"]
  }

  healthcheck {
    test     = ["CMD", "redis-cli", "ping"]
    interval = "5s"
    timeout  = "3s"
    retries  = 5
  }

  wait         = true
  wait_timeout = 60
}

# ---------- App ----------
resource "docker_container" "app" {
  name    = "${var.project}-app"
  image   = var.app_image
  restart = "unless-stopped"

  env = [
    "DB_HOST=db",
    "REDIS_HOST=redis",
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${random_password.db.result}",
    "POSTGRES_DB=${var.db_name}",
  ]

  ports {
    internal = 8000
    external = var.app_port
    ip       = "127.0.0.1"
  }

  networks_advanced {
    name = docker_network.net.name
  }

  # Dependencia explícita: las variables usan strings ("db"), no referencias
  depends_on = [
    docker_container.db,
    docker_container.redis,
  ]
}