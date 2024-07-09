data "aws_iam_policy_document" "ecs_execution_role_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    effect = "Allow"

    principals {
      identifiers = [
        "ec2.amazonaws.com",
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com",
        "batch.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name = local.ecs_execution_role_name
  # Read more about ECS' `task_role` and `execution_role` here https://stackoverflow.com/a/49947471
  description        = "This role is passed to our AWS ECS' task definition as the `execution_role`. This allows things like the correct image to be pulled and logs to be stored."
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_role_assume_role.json

  tags = var.standard_tags
}

data "aws_iam_policy_document" "ecs_task_execution_policy" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    # The `"Resource": "*"` is not a concern and the policy that Amazon suggests using
    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
    resources = [
      "*"
    ]
  }

  #########################
  # SYSO Custom S3 Access #
  #########################
  statement {
    sid = "MetaflowECSS3Permissions"

    effect = "Allow"

    actions = [
      "s3:*"
    ]

    resources = [
      # "arn:aws:s3:::s3://dev-ercot*",
      # "arn:aws:s3:::s3://dev-metaflow*",
      # "arn:aws:s3:::s3://dev-ds*"
      for bucket in s3_access_buckets :
      "arn:aws:s3:::${bucket}"
    ]
  }

}

resource "aws_iam_role_policy" "grant_ecs_access" {
  name   = "ecs_access"
  role   = aws_iam_role.ecs_execution_role.name
  policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

##############################
# SYSO Custom Secrets Access #
##############################

resource "aws_iam_role_policy_attachment" "batch_metaflow_secrets_access" {
  role       = aws_iam_role.batch_execution_role.name
  policy_arn = aws_iam_policy.batch_metaflow_access_secrets.arn
}

resource "aws_iam_policy" "batch_metaflow_access_secrets" {
  name        = "batch-metaflow-secrets-access"
  description = "Policy to allow metaflow to access secrets in Secrets Manager through Batch."
  policy      = data.aws_iam_policy_document.batch_metaflow_access_secrets.json
}

data "aws_secretsmanager_secret" "batch_metaflow_secret_name" {
  name = "morningstar"
}

# data "aws_secretsmanager_secrets" "metaflow_secrets_access" {
#   filter {
#     name   = "name"
#     values = [for secret_name in secrets_access :
#       "${secret_name}"
#       ]
#   }
# }

data "aws_iam_policy_document" "batch_metaflow_access_secrets" {

  statement {
    sid    = "ReadAWSSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:*"
    ]
    resources = [
      #data.aws_secretsmanager_secret.batch_metaflow_access_secrets[0].arn
      data.aws_secretsmanager_secret.batch_metaflow_secret_name.arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets"
    ]
    resources = [
      "*"
    ]
  }
}