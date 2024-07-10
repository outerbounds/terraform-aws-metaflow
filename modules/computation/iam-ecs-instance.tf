data "aws_iam_policy_document" "ecs_instance_role_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    effect = "Allow"

    principals {
      identifiers = [
        "ec2.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name = local.ecs_instance_role_name
  # Learn more by reading this Terraform documentation https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_compute_environment#argument-reference
  # Learn more by reading this AWS Batch documentation https://docs.aws.amazon.com/batch/latest/userguide/service_IAM_role.html
  description = "This role is passed to AWS Batch as a `instance_role`. This allows our Metaflow Batch jobs to execute with proper permissions."

  assume_role_policy = data.aws_iam_policy_document.ecs_instance_role_assume_role.json
}

/*
 Attach policy AmazonEC2ContainerServiceforEC2Role to ecs_instance_role. The
 policy is what the role is allowed to do similar to rwx for a user.
 AmazonEC2ContainerServiceforEC2Role is a predefined set of permissions by aws the
 permissions given are at:
 https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html
*/
resource "aws_iam_role_policy_attachment" "ecs_instance_role" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:${var.iam_partition}:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

####################
# Custom S3 Access #
####################

resource "aws_iam_role_policy_attachment" "ecs_instance_role_for_s3" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:${var.iam_partition}:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy" "metaflow_ecs_instance_s3_policy" {
  name        = "Metaflow-ECS-instance-s3-policy"
  description = "S3 policy for Metaflow ECS Instance"
  policy      = data.aws_iam_policy_document.custom_s3_policy_for_ecs_instance.json
}

data "aws_iam_policy_document" "custom_s3_policy_for_ecs_instance" {
  statement {
    sid = "MetaflowBatchS3Permissions"

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

data "aws_secretsmanager_secrets" "metaflow_secrets_access" {
  filter {
    name   = "name"
    values = [for secret_name in secrets_access :
      "${secret_name}"
      ]
  }
}

data "aws_iam_policy_document" "batch_metaflow_access_secrets" {

  statement {
    sid    = "ReadAWSSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:*"
    ]
    resources = [
      data.aws_secretsmanager_secret.metaflow_access_secrets.arns
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
