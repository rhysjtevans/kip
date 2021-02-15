data "archive_file" "lambda_oauth_validation" {
  type        = "zip"
  source_dir = "${path.module}/lambda/oauth_validation/"
  output_path = "${local.lambda_output}/lambda.oauth_validation.zip"
}


data "aws_iam_policy_document" "lambda_oauth_validation" {
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




resource "aws_iam_policy" "oauth_validation" {
   name = "${local.prefix}-lambda-policy-oauth_validation"
   path = "/"
   policy = data.aws_iam_policy_document.lambda_oauth_validation.json
}

// */

resource "aws_iam_policy_attachment" "oauth_validation" {
  name = "policy"
  roles = [aws_iam_role.lambda_oauth_validation.name]
  policy_arn = aws_iam_policy.oauth_validation.arn
}


resource "aws_lambda_function" "oauth_validation" {
  filename         = "${local.lambda_output}/lambda.oauth_validation.zip"
  timeout          = 900
  function_name    = "${local.prefix}-oauth_validation"
  role             = aws_iam_role.lambda_oauth_validation.arn
  handler          = "handler.lambda_handler"
  publish = true
  source_code_hash = data.archive_file.lambda_oauth_validation.output_base64sha256
  runtime          = "python3.6"
  memory_size      = 128
  environment {
    variables = local.lambda_variables
  }
}
resource "aws_iam_role" "lambda_oauth_validation" {
  name               = "keybase-${local.api_fqdn}-${local.env_name}-oauth_validation"
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


resource "aws_lambda_permission" "oauth_validation" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.oauth_validation.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  # source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.default.id}/*/${aws_api_gateway_method.profile.http_method}${aws_api_gateway_resource.profile_root.path}/*"
  source_arn = "${aws_api_gateway_rest_api.default.execution_arn}/*/${aws_api_gateway_integration.oauth_validation.http_method}/*"
}
