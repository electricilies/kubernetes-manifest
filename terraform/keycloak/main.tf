terraform {
  required_version = ">= 1.13.4"
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = ">= 5.5.0"
    }
  }
}

resource "keycloak_realm" "electricilies" {
  realm                    = "electricilies-dev"
  duplicate_emails_allowed = false
  login_with_email_allowed = true
  registration_allowed     = true
  remember_me              = true
  reset_password_allowed   = true
  verify_email             = true
  attributes = {
    userProfileEnable = true
  }
}

resource "keycloak_openid_client" "backend" {
  realm_id                 = keycloak_realm.electricilies.id
  client_id                = "backend"
  name                     = "Backend"
  access_type              = "CONFIDENTIAL"
  client_secret            = var.backend_client_secret
  service_accounts_enabled = true # FIXME: Why backend require this?
}

resource "keycloak_openid_client" "frontend" {
  realm_id                        = keycloak_realm.electricilies.id
  client_id                       = "frontend"
  access_type                     = "CONFIDENTIAL"
  name                            = "Frontend"
  client_secret                   = var.frontend_client_secret
  standard_flow_enabled           = true
  standard_token_exchange_enabled = true
  direct_access_grants_enabled    = true
  root_url                        = var.frontend_root_url
  base_url                        = var.frontend_base_url
  valid_redirect_uris             = ["*"]
  web_origins                     = var.frontend_web_origins
  admin_url                       = var.frontend_admin_url
}

resource "keycloak_realm_user_profile" "userprofile" {
  realm_id = keycloak_realm.electricilies.id

  attribute {
    name = "username"
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
    required_for_roles = ["admin", "user"]
  }

  attribute {
    name         = "first_name"
    display_name = "First Name"
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
    required_for_roles = ["admin", "user"]
  }

  attribute {
    name         = "last_name"
    display_name = "Last Name"
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
    required_for_roles = ["admin", "user"]
  }

  attribute {
    name = "email"
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
    required_for_roles = ["admin", "user"]
  }

  attribute {
    name         = "phone_number"
    display_name = "Phone Number"
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
    validator {
      name = "pattern"
      config = {
        pattern = "^0[0-9]{9,10}$"
      }
    }
    required_for_roles = ["admin", "user"]
  }

  attribute {
    name         = "address"
    display_name = "Address"
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
    required_for_roles = ["admin", "user"]
  }

  attribute {
    name         = "date_of_birth"
    display_name = "Date of birth"
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
    annotations = {
      inputType = "html5-date"
    }
    required_for_roles = ["admin", "user"]
  }

  attribute {
    name         = "deleted-at"
    display_name = "Deleted At"
    permissions {
      view = ["admin"]
      edit = ["admin"]
    }
    annotations = {
      inputType = "html5-datetime-local"
    }
  }
}

locals {
  roles = [
    "admin",
    "staff",
    "customer"
  ]
}

resource "keycloak_role" "backend_roles" {
  for_each = toset(local.roles)

  realm_id  = keycloak_realm.electricilies.id
  client_id = keycloak_openid_client.backend.id
  name      = each.key
}

resource "keycloak_default_roles" "default_roles" {
  realm_id = keycloak_realm.electricilies.id
  default_roles = [
    "${keycloak_openid_client.backend.client_id}/${keycloak_role.backend_roles["customer"].name}",
  ]
}
