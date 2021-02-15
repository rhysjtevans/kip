resource "aws_dynamodb_table" "keybase_proofs" {
  name           = "keybase-${replace(var.identity_domain,".","")}-${local.env_name}-proofs"
  billing_mode   = "PAY_PER_REQUEST"
#   read_capacity  = 20
#   write_capacity = 20
  hash_key       = "kb_username"
#   range_key      = "GameTitle"

  attribute {
    name = "kb_username"
    type = "S"
  }

    server_side_encryption{
        enabled = true
    }
  tags = {
    Name        = "keybase-proofs-${local.env_name}"
    Environment = local.env_name
  }
}


resource "aws_dynamodb_table" "keybase_proof_validation" {
  name           = "${local.prefix}-prevalidation"
  billing_mode   = "PAY_PER_REQUEST"
#   read_capacity  = 20
#   write_capacity = 20
  hash_key       = "kb_username"
#   range_key      = "GameTitle"

  attribute {
    name = "kb_username"
    type = "S"
  }

  attribute {
    name = "username"
    type = "S"
  }
  global_secondary_index {
    name            = "username"
    hash_key        = "username"
    write_capacity  = 0
    read_capacity   = 0
    projection_type = "KEYS_ONLY"
  }
    server_side_encryption{
        enabled = true
    }
  tags = {
    Name        = "keybase-proofs-${local.env_name}"
    Environment = local.env_name
  }
}
