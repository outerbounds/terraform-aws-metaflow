data "aws_iam_role" "step_functions_role" {
  name = var.step_functions_role_name
  count = var.step_functions_role_name == "" ? 0 : 1
}

locals {
  dynamodb_step_functions_state_db_name = "${var.resource_prefix}step_functions_state${var.resource_suffix}"
  
  step_functions_role_id = var.step_functions_role_name == "" ? aws_iam_role.step_functions_role[0].id : data.step_functions_role.id
  step_functions_role_arn = var.step_functions_role_name == "" ? aws_iam_role.step_functions_role[0].arn : data.step_functions_role.arn
}
