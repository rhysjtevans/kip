data "aws_iam_policy_document" "apigw_keybaseconfig" {
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
      aws_s3_bucket.keybase-config.arn
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




resource "aws_iam_policy" "keybase-config" {
   name = "${local.prefix}-lambda-policy-keybase-config"
   path = "/"
   policy = data.aws_iam_policy_document.apigw_keybaseconfig.json
}

// */

resource "aws_iam_policy_attachment" "keybase-config" {
  name = "policy"
  roles = [aws_iam_role.apigw_keybase-config.name]
  policy_arn = aws_iam_policy.keybase-config.arn
}

resource "aws_iam_role" "apigw_keybase-config" {
  name               = "keybase-${local.api_fqdn}-${local.env_name}-keybase-config"
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




















resource "aws_api_gateway_resource" "full-color-logo" {
  path_part   = "full-color.logo.svg"
  parent_id   = aws_api_gateway_resource.static.id
  rest_api_id = aws_api_gateway_rest_api.default.id
}

resource "aws_api_gateway_method" "item" {
  rest_api_id   = aws_api_gateway_rest_api.default.id
  resource_id   = aws_api_gateway_resource.item.id
  http_method   = "GET"
  authorization = "NONE"
  # request_parameters = {
  #   "method.request.path.item" = true
    
  # }
}

resource "aws_api_gateway_method_response" "item_200" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_resource.item.id
  http_method = aws_api_gateway_method.item.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  
}

resource "aws_api_gateway_integration" "item" {
  rest_api_id             = aws_api_gateway_rest_api.default.id
  resource_id             = aws_api_gateway_resource.item.id
  http_method             = aws_api_gateway_method.item.http_method
  integration_http_method = "GET"
  type                    = "AWS"
  # uri                     = "https://s3.eu-west-2.amazonaws.com/${aws_s3_bucket.keybase-config.id}/{item}"
  uri = "arn:aws:apigateway:eu-west-2:s3:path/${aws_s3_bucket.keybase-config.id}/keybase-config.json"
  credentials = aws_iam_role.apigw_keybase-config.arn
  
  # request_parameters = {
  #   "integration.request.path.item" = "method.request.path.item"
  # }

  passthrough_behavior = "WHEN_NO_MATCH"
  # request_templates = {
  #   "application/json" = ""
  # }

}

resource "aws_api_gateway_integration_response" "item" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_resource.item.id
  http_method = aws_api_gateway_method.item.http_method
  status_code = aws_api_gateway_method_response.item_200.status_code
  
  response_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_integration.item
  ]

}
