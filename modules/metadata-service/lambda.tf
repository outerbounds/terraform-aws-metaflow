data "aws_iam_policy_document" "lambda_ecs_execute_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "lambda_ecs_execute_role" {
  name               = local.lambda_ecs_execute_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_ecs_execute_role.json

  tags = var.standard_tags
}

data "aws_iam_policy_document" "lambda_ecs_task_execute_policy_cloudwatch" {
  statement {
    sid    = "CreateLogGroup"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup"
    ]

    resources = [
      "${local.cloudwatch_logs_arn_prefix}:*"
    ]
  }

  statement {
    sid    = "LogEvents"
    effect = "Allow"

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream"
    ]

    resources = [
      "${local.cloudwatch_logs_arn_prefix}:log-group:/aws/lambda/${local.db_migrate_lambda_name}:*"
    ]
  }
}

data "aws_iam_policy_document" "lambda_ecs_task_execute_policy_vpc" {
  statement {
    sid    = "NetInts"
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "grant_lambda_ecs_cloudwatch" {
  name   = "cloudwatch"
  role   = aws_iam_role.lambda_ecs_execute_role.name
  policy = data.aws_iam_policy_document.lambda_ecs_task_execute_policy_cloudwatch.json
}

resource "aws_iam_role_policy" "grant_lambda_ecs_vpc" {
  name   = "ecs_task_execute"
  role   = aws_iam_role.lambda_ecs_execute_role.name
  policy = data.aws_iam_policy_document.lambda_ecs_task_execute_policy_vpc.json
}

data "archive_file" "db_migrate_lambda" {
  type             = "zip"
  output_file_mode = "0666"
  output_path      = local.db_migrate_lambda_zip_file

  source {
    content  = <<EOF
import os, json
from urllib import request

def handler(event, context):
  response = {}
  status_endpoint = "{}/db_schema_status".format(os.environ.get('MD_LB_ADDRESS'))
  upgrade_endpoint = "{}/upgrade".format(os.environ.get('MD_LB_ADDRESS'))

  with request.urlopen(status_endpoint) as status:
    response['init-status'] = json.loads(status.read())

  upgrade_patch = request.Request(upgrade_endpoint, method='PATCH')
  with request.urlopen(upgrade_patch) as upgrade:
    response['upgrade-result'] = upgrade.read().decode()

  with request.urlopen(status_endpoint) as status:
    response['final-status'] = json.loads(status.read())

  print(response)
  return(response)
EOF
    filename = "index.py"
  }
}

resource "aws_lambda_function" "db_migrate_lambda" {
  function_name    = local.db_migrate_lambda_name
  handler          = "index.handler"
  runtime          = "python3.12"
  memory_size      = 128
  timeout          = 900
  description      = "Trigger DB Migration"
  filename         = local.db_migrate_lambda_zip_file
  source_code_hash = data.archive_file.db_migrate_lambda.output_base64sha256
  role             = aws_iam_role.lambda_ecs_execute_role.arn
  tags             = var.standard_tags

  environment {
    variables = {
      MD_LB_ADDRESS = "http://${aws_lb.this.dns_name}:8082"
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.metadata_service_security_group.id]
  }
}
