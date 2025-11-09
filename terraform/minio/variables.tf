variable "minio_server_endpoint" {
  type = string
}

variable "minio_username" {
  type = string
}

variable "minio_password" {
  type      = string
  sensitive = true
}
