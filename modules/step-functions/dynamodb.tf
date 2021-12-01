resource "aws_dynamodb_table" "step_functions_state_table" {
  count        = var.active ? 1 : 0
  name         = local.dynamodb_step_functions_state_db_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pathspec"

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = false
  }

  attribute {
    name = "pathspec"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = var.standard_tags
}
