resource "random_uuid" "s3-keybaseconfig" { }

data "template_file" "keybase-config" {
  template = file("${path.module}/files/keybase-proof-config.json.tpl")
  vars = {
    keybase_fqdn = local.api_fqdn    
    keybase_api_domain = var.keybase_api_domain
    identity_domain = var.identity_domain
    display_name = var.keybase_displayname
    brand_color = var.keybase_brandcolor
    description = var.keybase_description
    version = var.keybase_version
  }
}

resource "aws_s3_bucket" "keybase-config" {
  bucket = random_uuid.s3-keybaseconfig.result
  acl    = "public-read"

  tags = {
    Name        = "Keybase Config"
    Environment = local.env_name
    IdentityDomain = var.identity_domain
  }
  versioning {
    enabled = true
  }
}









data "template_file" "html-oauthcallback" {
  template = file("${path.module}/files/oauth_callback.html.tpl")
  vars = {
    OAUTH_CALLBACK_URI = "https://${local.api_fqdn}/oauth_validation"
  }
}
#  __    __  .______    __        ______        ___       _______  
# |  |  |  | |   _  \  |  |      /  __  \      /   \     |       \ 
# |  |  |  | |  |_)  | |  |     |  |  |  |    /  ^  \    |  .--.  |
# |  |  |  | |   ___/  |  |     |  |  |  |   /  /_\  \   |  |  |  |
# |  `--'  | |  |      |  `----.|  `--'  |  /  _____  \  |  '--'  |
#  \______/  | _|      |_______| \______/  /__/     \__\ |_______/ 
                                                                 
resource "aws_s3_bucket_object" "keybase-config" {
  bucket = aws_s3_bucket.keybase-config.id
  key    = "keybase-config.json"
  content = data.template_file.keybase-config.rendered
  acl = "public-read"
}


resource "aws_s3_bucket_object" "small-logo" {
  bucket = aws_s3_bucket.keybase-config.id
  key    = "small-black-logo.svg"
  source = "${path.module}/files/small-black-logo.svg"
}

resource "aws_s3_bucket_object" "full-logo" {
  bucket = aws_s3_bucket.keybase-config.id
  key    = "full-color.logo.svg"
  source = "${path.module}/files/full-color.logo.svg"
}



                                                               
resource "aws_s3_bucket_object" "htmlredirect" {
  bucket = aws_s3_bucket.keybase-config.id
  key    = "oauth_callback.html"
  content = data.template_file.html-oauthcallback.rendered
  acl = "public-read"
}



output "keybase-config" {
  description = "Provide this keybase config URI to keybase.io/mlsteele"
  value       = "https://${local.api_fqdn}/static/keybase-config.json"
}
