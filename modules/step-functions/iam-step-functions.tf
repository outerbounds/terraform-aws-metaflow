data "aws_iam_policy_document" "step_functions_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [
        "states.amazonaws.com"
      ]
      type = "Service"
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "step_functions_batch_policy" {
  statement {
    actions = [
      "batch:TerminateJob",
      "batch:DescribeJobs",
      "batch:DescribeJobDefinitions",
      "batch:DescribeJobQueues",
      "batch:RegisterJobDefinition",
      "batch:TagResource"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "batch:SubmitJob"
    ]

    resources = [
      var.batch_job_queue_arn,
      "arn:${var.iam_partition}:batch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:job-definition/*"
    ]
  }
}

data "aws_iam_policy_document" "step_functions_s3" {
  statement {
    actions = [
      "s3:ListBucket"
    ]

    resources = [
      var.s3_bucket_arn
    ]
  }

  statement {
    actions = [
      "s3:*Object"
    ]

    resources = [
      var.s3_bucket_arn, "${var.s3_bucket_arn}/*"
    ]
  }

  statement {
    actions = [
      "kms:Decrypt"
    ]

    resources = [
      var.s3_bucket_kms_arn
    ]
  }
}

data "aws_iam_policy_document" "step_functions_cloudwatch" {
  statement {
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "step_functions_eventbridge" {
  statement {
    actions = [
      "events:PutTargets",
      "events:DescribeRule"
    ]

    resources = [
      "arn:${var.iam_partition}:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/StepFunctionsGetEventsForBatchJobsRule",
    ]
  }

  statement {
    actions = [
      "events:PutRule"
    ]

    resources = [
      "arn:${var.iam_partition}:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/StepFunctionsGetEventsForBatchJobsRule"
    ]

    condition {
      test     = "StringEquals"
      variable = "events:detail-type"
      values   = ["Batch Job State Change"]
    }
  }
}

data "aws_iam_policy_document" "step_functions_dynamodb" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem"
    ]

    resources = [
      join("", [for arn in aws_dynamodb_table.step_functions_state_table.*.arn : arn])
    ]
  }
}

resource "aws_iam_role" "step_functions_role" {
  name               = "${var.resource_prefix}step_functions_role${var.resource_suffix}"
  description        = "IAM role for AWS Step Functions to access AWS resources (AWS Batch, AWS DynamoDB)."
  assume_role_policy = data.aws_iam_policy_document.step_functions_assume_role_policy.json

  tags = var.standard_tags
}

resource "aws_iam_role_policy" "step_functions_batch" {
  name   = "aws_batch"
  role   = aws_iam_role.step_functions_role.id
  policy = data.aws_iam_policy_document.step_functions_batch_policy.json
}

resource "aws_iam_role_policy" "step_functions_s3" {
  name   = "s3"
  role   = aws_iam_role.step_functions_role.id
  policy = data.aws_iam_policy_document.step_functions_s3.json
}

resource "aws_iam_role_policy" "step_functions_cloudwatch" {
  name   = "cloudwatch"
  role   = aws_iam_role.step_functions_role.id
  policy = data.aws_iam_policy_document.step_functions_cloudwatch.json
}

resource "aws_iam_role_policy" "step_functions_eventbridge" {
  name   = "event_bridge"
  role   = aws_iam_role.step_functions_role.id
  policy = data.aws_iam_policy_document.step_functions_eventbridge.json
}

resource "aws_iam_role_policy" "step_functions_dynamodb" {
  name   = "dynamodb"
  role   = aws_iam_role.step_functions_role.id
  policy = data.aws_iam_policy_document.step_functions_dynamodb.json
}
