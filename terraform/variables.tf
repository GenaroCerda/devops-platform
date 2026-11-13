variable "project" {
  description = "Prefijo para nombrar todos los recursos"
  type        = string
  default     = "tf-lab"
}

variable "app_image" {
  description = "Imagen de la app (debe existir localmente)"
  type        = string
  default     = "mi-api:1.0.0"
}

variable "app_port" {
  description = "Puerto del host donde se publica la app"
  type        = number
  default     = 8082

  validation {
    condition     = var.app_port > 1024 && var.app_port < 65536
    error_message = "El puerto debe estar entre 1025 y 65535."
  }
}

variable "db_name" {
  type    = string
  default = "miapi"
}

variable "db_user" {
  type    = string
  default = "miapi"
}