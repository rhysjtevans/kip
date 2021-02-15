data "archive_file" "lambda_new_profile_proof" {
  type        = "zip"
  source_file = "${path.module}/lambda/new-profile-proof/handler.py"
  output_path = "${local.lambda_output}/lambda.new-profile-proof.zip"
}



data "aws_iam_policy_document" "lambda_new-profile-proof" {
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
      aws_lambda_function.new_profile_proof.arn
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
      aws_dynamodb_table.keybase_proofs.arn,
      aws_dynamodb_table.keybase_proof_validation.arn
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




resource "aws_iam_policy" "new_profile_proof" {
   name = "${local.prefix}-lambda-policy-new_profile_proof"
   path = "/"
   policy = data.aws_iam_policy_document.lambda_new-profile-proof.json
}

// */

resource "aws_iam_policy_attachment" "new_profile_proof" {
  name = "policy"
  roles = [aws_iam_role.lambda_new_profile_proof.name]
  policy_arn = aws_iam_policy.new_profile_proof.arn
}


resource "aws_lambda_function" "new_profile_proof" {
  filename         = "${local.lambda_output}/lambda.new-profile-proof.zip"
  timeout          = 900
  function_name    = "${local.prefix}-new_profile_proof"
  role             = aws_iam_role.lambda_new_profile_proof.arn
  handler          = "handler.lambda_handler"
  publish = true
  source_code_hash = data.archive_file.lambda_new_profile_proof.output_base64sha256
  runtime          = "python3.6"
  memory_size      = 128
  environment {
    variables = local.lambda_variables
  }
}
resource "aws_iam_role" "lambda_new_profile_proof" {
  name               = "keybase-${local.api_fqdn}-${local.env_name}-new_profile_proof"
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


resource "aws_lambda_permission" "new-profile-proof" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.new_profile_proof.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  # source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.default.id}/*/${aws_api_gateway_method.profile.http_method}${aws_api_gateway_resource.profile_root.path}/*"
  source_arn = "${aws_api_gateway_rest_api.default.execution_arn}/*/${aws_api_gateway_integration.new_profile_proof.http_method}/*"
}
