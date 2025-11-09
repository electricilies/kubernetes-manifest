provider "minio" {
  minio_server   = var.minio_server_endpoint
  minio_user     = var.minio_username
  minio_password = var.minio_password
}
