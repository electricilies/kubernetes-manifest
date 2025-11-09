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
  service_accounts_enabled = true
}

resource "keycloak_openid_client" "frontend" {
  realm_id                        = keycloak_realm.electricilies.id
  client_id                       = "frontend"
  name                            = "Frontend"
  access_type                     = "CONFIDENTIAL"
  client_secret                   = var.frontend_client_secret
  standard_flow_enabled           = true
  standard_token_exchange_enabled = true
  direct_access_grants_enabled    = true
  root_url                        = var.frontend_root_url
  base_url                        = var.frontend_base_url
  valid_redirect_uris             = var.frontend_valid_redirect_uris
  web_origins                     = var.frontend_web_origins
  admin_url                       = var.frontend_admin_url
}

resource "keycloak_openid_client" "swagger" {
  realm_id              = keycloak_realm.electricilies.id
  client_id             = "swagger"
  name                  = "Swagger"
  access_type           = "PUBLIC"
  standard_flow_enabled = true
  valid_redirect_uris   = var.swagger_valid_redirect_uris
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
    validator {
      name = "person-name-prohibited-characters"
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
    validator {
      name = "person-name-prohibited-characters"
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
    annotations = {
      inputType = "html5-tel"
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
    display_name = "Date of Birth"
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
    annotations = {
      inputType = "html5-date"
    }
    required_for_roles = ["admin", "user"]
  }
}

locals {
  roles = [
    "admin",
    "staff",
    "customer"
  ]

  users = {
    admin = {
      password      = "admin",
      role          = "admin"
      first_name    = "admin",
      last_name     = "admin"
      email         = "admin@example.com"
      phone_number  = "0909909909"
      address       = "admin address"
      date_of_birth = "01/01/2001"
    },
    staff = {
      password      = "staff",
      role          = "staff",
      first_name    = "staff",
      last_name     = "staff"
      email         = "staff@example.com"
      phone_number  = "0909909909"
      address       = "staff address"
      date_of_birth = "01/01/2001"
    },
    customer = {
      password      = "customer",
      role          = "customer"
      first_name    = "customer",
      last_name     = "customer"
      email         = "customer@example.com"
      phone_number  = "0909909909"
      address       = "customer address"
      date_of_birth = "01/01/2001"
    },
  }
}

resource "keycloak_role" "roles" {
  for_each = toset(local.roles)

  realm_id = keycloak_realm.electricilies.id
  name     = each.key
}

resource "keycloak_default_roles" "default_roles" {
  realm_id = keycloak_realm.electricilies.id
  default_roles = [
    keycloak_role.roles["customer"].name
  ]
}

resource "keycloak_user" "users" {
  for_each = local.users
  depends_on = [
    keycloak_realm_user_profile.userprofile,
  ]

  realm_id = keycloak_realm.electricilies.id
  username = each.key
  initial_password {
    value     = each.value.password
    temporary = false
  }
  email          = each.value.email
  email_verified = true
  attributes = {
    first_name    = each.value.first_name
    role          = each.value.role,
    first_name    = each.value.first_name,
    last_name     = each.value.last_name,
    phone_number  = each.value.phone_number,
    address       = each.value.address,
    date_of_birth = each.value.date_of_birth,
  }
}

resource "keycloak_user_roles" "users" {
  for_each = local.users

  realm_id = keycloak_realm.electricilies.id
  user_id  = keycloak_user.users[each.key].id
  role_ids = [
    keycloak_role.roles[each.value.role].id,
  ]
}
