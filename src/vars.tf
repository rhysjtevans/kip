variable "cloudflare_token" { }

variable "region" {
  description = "The AWS region, e.g., eu-west-1"
}


variable "identity_domain" {
  description = "This is the user domain"
}


variable "keybase_displayname" {
  default = "Rhys Evans Company"
}
variable "keybase_brandcolor" {
  default = "#FFB800"
}
variable "keybase_description" {
  default = ""
}

variable "keybase_version" {}


variable "keybase_api_subdomain" {}

variable "keybase_api_domain" {}


variable "oauth_validation_audience" {
  description = "Also known as Client ID or App ID."
}

variable "oauth_validate_issuer" {
  default = true
}
variable "oauth_validate_audience" {
  default = true
}
variable "oauth_validate_lifetime" {
  default = false
}
variable "azuread_client_id" {}

variable "azuread_tenant_id" {}

variable "notificationwebhook" {
  default = ""
}


locals {
    env_name = terraform.workspace
    lambda_output = "${path.module}/bin"
    api_fqdn = "${var.keybase_api_subdomain}.${var.keybase_api_domain}"
    # oidc = jsonencode(data.http.oidc.body)
    # oidc_issuer = jsondecode(data.http.oidc.body)["issuer"]
    # oidc_issuer = "https://login.microsoftonline.com/23964C2B-8ECA-4C7C-902C-9E19F24C0247/v2.0"
    # oidc_authorization_endpoint = jsondecode(data.http.oidc.body)["authorization_endpoint"]
    # oidc_authorization_endpoint = "https://login.microsoftonline.com/23964C2B-8ECA-4C7C-902C-9E19F24C0247/oauth2/v2.0/authorize"

    prefix = "kis-${replace(var.identity_domain,".","")}-${local.env_name}"
    oidc_uri = "https://login.microsoftonline.com/${var.azuread_tenant_id}/v2.0/.well-known/openid-configuration"

    lambda_variables = {
      api_fqdn = local.api_fqdn
      dynamodb_table_validationproof = aws_dynamodb_table.keybase_proof_validation.id
      dynamodb_table_proof = aws_dynamodb_table.keybase_proofs.id

      NotificationWebHook = var.notificationwebhook

      IdentityDomain = var.identity_domain
      oauth_authorise_endpoint = jsondecode(data.http.oidc.body)["authorization_endpoint"]
      oauth_validation_audience = var.oauth_validation_audience
      oauth_validation_issuer = jsondecode(data.http.oidc.body)["issuer"]
      api_fqdn = local.api_fqdn
      oauth_validate_issuer = var.oauth_validate_issuer
      oauth_validate_lifetime = var.oauth_validate_lifetime
      oauth_validate_audience = var.oauth_validate_audience
      oidc_uri = local.oidc_uri
      oidc_jwks_uri = jsondecode(data.http.oidc.body)["jwks_uri"]
      
      # oidc_jwks_uri = "https://login.microsoftonline.com/23964C2B-8ECA-4C7C-902C-9E19F24C0247/discovery/v2.0/keys"
    }
}

data "http" "oidc" {
  url = local.oidc_uri
  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}


# variable "keybase_cfg_" {
#   default = ""
# }
