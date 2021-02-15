
resource "aws_api_gateway_resource" "profile_root" {
  path_part   = "profile"
  parent_id   = aws_api_gateway_rest_api.default.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.default.id
}



resource "aws_api_gateway_resource" "profile" {
  path_part   = "{profile}"
  parent_id   = aws_api_gateway_resource.profile_root.id
  rest_api_id = aws_api_gateway_rest_api.default.id
}

resource "aws_api_gateway_method" "profile" {
  rest_api_id   = aws_api_gateway_rest_api.default.id
  resource_id   = aws_api_gateway_resource.profile.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "profile" {
  rest_api_id             = aws_api_gateway_rest_api.default.id
  resource_id             = aws_api_gateway_resource.profile.id
  http_method             = aws_api_gateway_method.profile.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.profile.invoke_arn
  credentials = aws_iam_role.lambda_profile.arn
}


resource "aws_api_gateway_method_response" "profile_200" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_resource.profile.id
  http_method = aws_api_gateway_method.profile.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  
}

resource "aws_api_gateway_method_response" "profile_400" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_resource.profile.id
  http_method = aws_api_gateway_method.profile.http_method
  status_code = "400"
  response_models = {
    "application/json" = "Empty"
  }
  
}