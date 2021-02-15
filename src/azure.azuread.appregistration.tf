


resource "azuread_application" "kip" {
  name                       = "Keybase Identity Service (${local.env_name})"
  homepage                   = "https://github.com/rhysjtevans/keybase-identity-provider"
  reply_urls                 = ["https://${var.keybase_api_subdomain}.${var.identity_domain}/oauth-callback"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
  
  type                       = "webapp/api"
}
