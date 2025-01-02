data "aws_iam_policy_document" "eventbridge_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [
        "events.amazonaws.com"
      ]
      type = "Service"
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "eventbridge_step_functions_policy" {
  statement {
    actions = [
      "states:StartExecution"
    ]

    resources = [
      "arn:${var.iam_partition}:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stateMachine:*"
    ]
  }
}

resource "aws_iam_role" "eventbridge_role" {
  name               = "${var.resource_prefix}eventbridge_role${var.resource_suffix}"
  description        = "IAM role for Amazon EventBridge to access AWS Step Functions."
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role_policy.json

  tags = var.standard_tags
}

resource "aws_iam_role_policy" "eventbridge_step_functions_policy" {
  name   = "step_functions"
  role   = aws_iam_role.eventbridge_role.id
  policy = data.aws_iam_policy_document.eventbridge_step_functions_policy.json
}
