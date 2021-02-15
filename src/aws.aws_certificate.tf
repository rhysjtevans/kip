resource "aws_acm_certificate" "keybase_cert" {
  domain_name       = local.api_fqdn
  validation_method = "DNS"
  provider = aws.us-east-1
  tags = {
    Environment = "${local.prefix}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# ____    ____  ___       __       __   _______       ___   .___________. __    ______   .__   __. 
# \   \  /   / /   \     |  |     |  | |       \     /   \  |           ||  |  /  __  \  |  \ |  | 
#  \   \/   / /  ^  \    |  |     |  | |  .--.  |   /  ^  \ `---|  |----`|  | |  |  |  | |   \|  | 
#   \      / /  /_\  \   |  |     |  | |  |  |  |  /  /_\  \    |  |     |  | |  |  |  | |  . `  | 
#    \    / /  _____  \  |  `----.|  | |  '--'  | /  _____  \   |  |     |  | |  `--'  | |  |\   | 
#     \__/ /__/     \__\ |_______||__| |_______/ /__/     \__\  |__|     |__|  \______/  |__| \__| 

resource "aws_acm_certificate_validation" "keybase_cert" {
  provider = aws.us-east-1
  certificate_arn         = aws_acm_certificate.keybase_cert.arn
  validation_record_fqdns = [aws_acm_certificate.keybase_cert.domain_validation_options.0.resource_record_name]
  depends_on = [
    cloudflare_record.aws_caa1,
    cloudflare_record.aws_caa2,
    cloudflare_record.aws_iodef 
  ]
}
