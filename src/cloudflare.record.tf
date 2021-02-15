resource "cloudflare_record" "keybase_fqdn" {
  domain = var.keybase_api_domain
  name   = var.keybase_api_subdomain
  value  = aws_api_gateway_domain_name.keybase_fqdn.cloudfront_domain_name
  # value = "google.com"
  type   = "CNAME"
  ttl    = 120
}


resource "cloudflare_record" "aws_caa1" {
  domain  = var.keybase_api_domain
  name    = var.keybase_api_subdomain
  data    = {
    flags = "0"
    tag   = "issue"
    value = "amazon.com"
  }
  type    = "CAA"
  ttl     = 1
  }

resource "cloudflare_record" "aws_caa2" {
  domain  = var.keybase_api_domain
  name    = var.keybase_api_subdomain
  data    = {
    flags = "0"
    tag   = "issuewild"
    value = "amazon.com"
  }
  type    = "CAA"
  ttl     = 1
}



resource "cloudflare_record" "aws_iodef" {
  domain  = var.keybase_api_domain
  name    = var.keybase_api_subdomain
  data    = {
    flags = "0"
    tag   = "iodef"
    value = "mailto:caa@${var.identity_domain}"
  }
  type    = "CAA"
  ttl     = 1
  }





                                                                                                 
resource "cloudflare_record" "keybase_cert" {
  domain = var.keybase_api_domain
  
  name   = aws_acm_certificate.keybase_cert.domain_validation_options.0.resource_record_name
  value  = substr(aws_acm_certificate.keybase_cert.domain_validation_options.0.resource_record_value,0,length(aws_acm_certificate.keybase_cert.domain_validation_options.0.resource_record_value)-1)
  type   = aws_acm_certificate.keybase_cert.domain_validation_options.0.resource_record_type
  ttl    = 120
}