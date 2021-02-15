resource "aws_api_gateway_resource" "new_profile_proof" {
  path_part   = "new-profile-proof"
  parent_id   = aws_api_gateway_rest_api.default.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.default.id
}

resource "aws_api_gateway_method" "new_profile_proof" {
  rest_api_id   = aws_api_gateway_rest_api.default.id
  resource_id   = aws_api_gateway_resource.new_profile_proof.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "new_profile_proof" {
  rest_api_id             = aws_api_gateway_rest_api.default.id
  resource_id             = aws_api_gateway_resource.new_profile_proof.id
  http_method             = aws_api_gateway_method.new_profile_proof.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.new_profile_proof.invoke_arn
}