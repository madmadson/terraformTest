variable "db_name" {
  description = "Name der DB"
  type        = string
  default     = "mylocaldb"
}

variable "db_user" {
  description = "Benutzername"
  type        = string
  default     = "localuser"
}

variable "db_password" {
  description = "Passwort"
  type        = string
  default     = "localpass"
}

variable "db_port" {
  description = "Port für Postgres"
  type        = number
  default     = 5433
}

variable "adminer_port" {
  description = "Adminer interner Port"
  type        = number
  default     = 8080
}

variable "proxy_port" {
  description = "Externer Port für nginx Proxy"
  type        = number
  default     = 8081
}

variable "volume_name" {
  description = "Name des Volumes"
  type        = string
  default     = "pg_local_volume"
}

variable "network_name" {
  description = "Docker-Netzwerkname"
  type        = string
  default     = "local_network"
}
