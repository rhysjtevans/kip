resource "aws_api_gateway_rest_api" "default" {
  name = "keybase"
  description = "Keybase API - ${local.prefix}"
}



resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_resource.check_proof,
    aws_api_gateway_method.check_proof,
    aws_api_gateway_integration.check_proof,
    aws_api_gateway_resource.new_profile_proof,
    aws_api_gateway_method.new_profile_proof,
    aws_api_gateway_integration.new_profile_proof,
    aws_api_gateway_resource.oauth_validation,
    aws_api_gateway_method.oauth_validation,
    aws_api_gateway_integration.oauth_validation,
    aws_api_gateway_method_response.oauth_callback_400,
    aws_api_gateway_resource.profile_root,
    aws_api_gateway_resource.profile,
    aws_api_gateway_method.profile,
    aws_api_gateway_integration.profile,
    aws_api_gateway_method_response.profile_200,
    aws_api_gateway_method_response.profile_400,
    aws_api_gateway_resource.item,
    aws_api_gateway_method.item,
    aws_api_gateway_method_response.item_200,
    aws_api_gateway_integration.item,
    aws_api_gateway_integration_response.item,
    aws_api_gateway_resource.oauth_callback,
    aws_api_gateway_method.oauth_callback,
    aws_api_gateway_method_response.oauth_callback_200,
    aws_api_gateway_integration.oauth_callback,
    aws_api_gateway_integration_response.oauth_callback,
    aws_api_gateway_resource.static,
    aws_api_gateway_rest_api.default,
    aws_api_gateway_domain_name.keybase_fqdn
    ]

  rest_api_id = aws_api_gateway_rest_api.default.id
  stage_name  = local.env_name
  

}

# resource "aws_api_gateway_method" "default" {
#   rest_api_id   = aws_api_gateway_rest_api.default.id
#   resource_id   = aws_api_gateway_resource.default.id
#   http_method   = "GET"
#   authorization = "NONE"
# }



# resource "aws_api_gateway_resource" "default" {
#   rest_api_id = aws_api_gateway_rest_api.default.id
#   parent_id   = aws_api_gateway_rest_api.default.root_resource_id
#   path_part   = "MOCK-IGNORE"
# }


# resource "aws_api_gateway_integration" "default" {
#   rest_api_id = aws_api_gateway_rest_api.default.id
#   resource_id = aws_api_gateway_method.default.resource_id
#   http_method = aws_api_gateway_method.default.http_method
#   type                    = "MOCK"
# }

/*
 _______ .__   __.      ___      .______    __       _______    .___________. __          _______.
|   ____||  \ |  |     /   \     |   _  \  |  |     |   ____|   |           ||  |        /       |
|  |__   |   \|  |    /  ^  \    |  |_)  | |  |     |  |__      `---|  |----`|  |       |   (----`
|   __|  |  . `  |   /  /_\  \   |   _  <  |  |     |   __|         |  |     |  |        \   \    
|  |____ |  |\   |  /  _____  \  |  |_)  | |  `----.|  |____        |  |     |  `----.----)   |   
|_______||__| \__| /__/     \__\ |______/  |_______||_______|       |__|     |_______|_______/    
At this time (Oct 2018) you have to direct it through a custom CloudFront distribution.                                                                                
*/

resource "aws_api_gateway_domain_name" "keybase_fqdn" {
  certificate_arn = aws_acm_certificate_validation.keybase_cert.certificate_arn
  domain_name     = local.api_fqdn
  security_policy = "TLS_1_2"
}

resource "aws_api_gateway_base_path_mapping" "default" {
  api_id      = aws_api_gateway_rest_api.default.id
  stage_name  = aws_api_gateway_deployment.deployment.stage_name
  domain_name = aws_api_gateway_domain_name.keybase_fqdn.domain_name
}


# resource "aws_cloudfront_distribution" "apigateway" {
#   aliases = [
#     local.api_fqdn
#   ]
#   is_ipv6_enabled = true
#   enabled = true
#   comment = element(split("/",aws_api_gateway_deployment.release.invoke_url),2)
#   http_version = "http2"
  
#   viewer_certificate {
#     acm_certificate_arn = aws_acm_certificate.keybase_cert.arn
#     minimum_protocol_version = "TLSv1.2_2018"
#     ssl_support_method = "sni-only"
#   }
#   origin {
#     domain_name = element(split("/",aws_api_gateway_deployment.release.invoke_url),2)
#     origin_id   = aws_api_gateway_deployment.release.id
#     # origin_path = ""
#     custom_origin_config {
#       https_port = 443
#       http_port = 80
#       origin_protocol_policy = "https-only"
#       origin_ssl_protocols = ["TLSv1.2"]
#       origin_keepalive_timeout = 60
#       origin_read_timeout = 60
#     }
#   }
#   restrictions { //required field
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }
#   default_cache_behavior {
#     allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#     cached_methods   = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id = aws_api_gateway_deployment.release.id

#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }
#     min_ttl                = 0
#     default_ttl            = 86400
#     max_ttl                = 31536000
#     compress               = false
    
#     viewer_protocol_policy = "redirect-to-https"
#   }
#   price_class = "PriceClass_100"
#   depends_on = [
#     "aws_acm_certificate_validation.keybase_cert"
#   ]
# #   logging_config {
# #     bucket = aws_s3_bucket.apigateway_logs.bucket_domain_name
# #     prefix = "logs/"
# #   }


# #   tags = "${merge(
# #       local.common_tags,
# #       map(
# #         "Name", "${local.env_name}-apigateway",
# #       )
# #     )}"
# }




# resource "aws_s3_bucket" "apigateway_logs" {
#   bucket = "logbucket"
#   acl    = "private"
#   tags = "${merge(
#       local.common_tags,
#       map(
#         "Name", "${local.env_name}-apigateway-logs",
#       )
#     )}"
  
# }
