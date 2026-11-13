output "app_url" {
  description = "URL de la app"
  value       = "http://localhost:${var.app_port}"
}

output "db_password" {
  description = "Contraseña generada para Postgres"
  value       = random_password.db.result
  sensitive   = true
}