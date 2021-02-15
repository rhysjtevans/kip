resource "aws_api_gateway_resource" "oauth_validation" {
  path_part   = "oauth_validation"
  parent_id   = aws_api_gateway_rest_api.default.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.default.id
}

resource "aws_api_gateway_method" "oauth_validation" {
  rest_api_id   = aws_api_gateway_rest_api.default.id
  resource_id   = aws_api_gateway_resource.oauth_validation.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "oauth_validation" {
  rest_api_id             = aws_api_gateway_rest_api.default.id
  resource_id             = aws_api_gateway_resource.oauth_validation.id
  http_method             = aws_api_gateway_method.oauth_validation.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.oauth_validation.invoke_arn
  credentials = aws_iam_role.lambda_oauth_validation.arn
}
resource "aws_api_gateway_method_response" "oauth_callback_400" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_resource.oauth_callback.id
  http_method = aws_api_gateway_method.oauth_callback.http_method
  status_code = "400"
  response_models = {
    "application/json" = "Empty"
  }
}