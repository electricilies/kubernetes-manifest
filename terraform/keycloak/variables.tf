variable "keycloak_url" {
  type = string
}

variable "terraform_client_secret" {
  type      = string
  sensitive = true
}

variable "backend_client_secret" {
  type      = string
  sensitive = true
}

variable "frontend_client_secret" {
  type      = string
  sensitive = true
}

variable "frontend_root_url" {
  type = string
}

variable "frontend_base_url" {
  type = string
}

variable "frontend_web_origins" {
  type = list(string)
}

variable "frontend_admin_url" {
  type    = string
  default = "/admin"
}
