resource "aws_api_gateway_resource" "static" {
  path_part   = "static"
  parent_id   = aws_api_gateway_rest_api.default.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.default.id
}

# resource "aws_api_gateway_method" "static" {
#   rest_api_id   = aws_api_gateway_rest_api.default.id
#   resource_id   = aws_api_gateway_resource.static.id
#   http_method   = "GET"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "static" {
#   rest_api_id             = aws_api_gateway_rest_api.default.id
#   resource_id             = aws_api_gateway_resource.static.id
#   http_method             = aws_api_gateway_method.static.http_method
# #   integration_http_method = "GET"
#   type                    = "MOCK"
# #   uri                     = aws_s3_bucket.keybase-config.id}/{item
# #   request_parameters = {
# #     "item" = "method.request.path.item"
# #   }
# }
