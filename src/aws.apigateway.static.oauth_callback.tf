data "aws_iam_policy_document" "apigw_oauth_callback" {
  statement {
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      resources = ["*"]
    
  }
  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:InvokeAsync"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "dynamodb:*"
    ]
    resources = [
      "*",
      "*"
    ]
  }
  statement {
    actions = [
      "S3:*"
    ]
    resources = [
      "*"
    ]
  }
#   statement {
#       actions = [
#           "s3:GetObject"
#       ]
#       resources = [
#           "${aws_s3_bucket.ping.arn}/*"
#       ]
#   }
#   statement {
#     actions = [
#       "s3:*"
#     ]
#     resources = [
#       [
#         "${aws_s3_bucket.pingsql.arn}/*",
#         aws_s3_bucket.pingsql.arn
#       ]
#     ]
#   }
}




resource "aws_iam_policy" "oauth_callback" {
   name = "${local.prefix}-apigateway-policy-oauth_callback"
   path = "/"
   policy = data.aws_iam_policy_document.apigw_oauth_callback.json
}

// */

resource "aws_iam_policy_attachment" "oauth_callback" {
  name = "policy"
  roles = [aws_iam_role.apigw_oauth_callback.name]
  policy_arn = aws_iam_policy.oauth_callback.arn
}

resource "aws_iam_role" "apigw_oauth_callback" {
  name               = "keybase-${local.api_fqdn}-${local.env_name}-apigw_oauth_callback"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "apigateway.amazonaws.com"
          ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  description        = "Required permissions for ping"
}



























resource "aws_api_gateway_resource" "oauth_callback" {
  path_part   = "oauth_callback"
  parent_id   = aws_api_gateway_resource.static.id
  rest_api_id = aws_api_gateway_rest_api.default.id
}

resource "aws_api_gateway_method" "oauth_callback" {
  rest_api_id   = aws_api_gateway_rest_api.default.id
  resource_id   = aws_api_gateway_resource.oauth_callback.id
  http_method   = "GET"
  authorization = "NONE"
  # request_parameters = {
  #   "method.request.path.oauth_callback" = true
    
  # }
}

resource "aws_api_gateway_method_response" "oauth_callback_200" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_resource.oauth_callback.id
  http_method = aws_api_gateway_method.oauth_callback.http_method
  status_code = "200"
  response_models = {
    "text/html" = "Empty"
  }
}

resource "aws_api_gateway_integration" "oauth_callback" {
  rest_api_id             = aws_api_gateway_rest_api.default.id
  resource_id             = aws_api_gateway_resource.oauth_callback.id
  http_method             = aws_api_gateway_method.oauth_callback.http_method
  integration_http_method = "GET"
  type                    = "AWS"
  # uri                     = "https://s3.eu-west-2.amazonaws.com/${aws_s3_bucket.oauth_callback.id}/{oauth_callback}"
  uri = "arn:aws:apigateway:eu-west-2:s3:path/${aws_s3_bucket.keybase-config.id}/oauth_callback.html"
  credentials = aws_iam_role.apigw_oauth_callback.arn
  
  # request_parameters = {
  #   "integration.request.path.oauth_callback" = "method.request.path.oauth_callback"
  # }

  passthrough_behavior = "WHEN_NO_MATCH"
  # request_templates = {
  #   "application/json" = ""
  # }

}

resource "aws_api_gateway_integration_response" "oauth_callback" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_resource.oauth_callback.id
  http_method = aws_api_gateway_method.oauth_callback.http_method
  status_code = aws_api_gateway_method_response.oauth_callback_200.status_code
  
  response_templates = {
    "text/html" = ""
  }
  depends_on = [
    aws_api_gateway_integration.oauth_callback
  ]

}
