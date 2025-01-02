# Move IAM role resources
moved {
  from = aws_iam_role.step_functions_role[0]
  to   = aws_iam_role.step_functions_role
}

moved {
  from = aws_iam_role.eventbridge_role[0]
  to   = aws_iam_role.eventbridge_role
}

# Move IAM policy resources
moved {
  from = aws_iam_role_policy.step_functions_batch[0]
  to   = aws_iam_role_policy.step_functions_batch
}

moved {
  from = aws_iam_role_policy.step_functions_s3[0]
  to   = aws_iam_role_policy.step_functions_s3
}

moved {
  from = aws_iam_role_policy.step_functions_cloudwatch[0]
  to   = aws_iam_role_policy.step_functions_cloudwatch
}

moved {
  from = aws_iam_role_policy.step_functions_eventbridge[0]
  to   = aws_iam_role_policy.step_functions_eventbridge
}

moved {
  from = aws_iam_role_policy.step_functions_dynamodb[0]
  to   = aws_iam_role_policy.step_functions_dynamodb
}

moved {
  from = aws_iam_role_policy.eventbridge_step_functions_policy[0]
  to   = aws_iam_role_policy.eventbridge_step_functions_policy
}

# Move DynamoDB resources
moved {
  from = aws_dynamodb_table.step_functions_state_table[0]
  to   = aws_dynamodb_table.step_functions_state_table
}
