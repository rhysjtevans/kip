
provider "cloudflare" {
  email = "rhys@acetechnet.co.uk"
  token = var.cloudflare_token
}

provider "aws" {
  version = ">= 2.23.0"
  region = "eu-west-2"
  shared_credentials_file = "~/.aws/credentials"
  profile = "keybase"
}

provider "aws" {
  version = ">= 2.23.0"
  region = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  profile = "keybase"
  alias = "us-east-1"
}

provider "azuread" {
  client_id = var.azuread_client_id 
  tenant_id = var.azuread_tenant_id
}

data "aws_caller_identity" "current" {}