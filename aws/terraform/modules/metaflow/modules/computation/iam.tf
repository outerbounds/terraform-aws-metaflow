data "aws_iam_policy_document" "ecs_execution_role" {
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
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_role.json

  tags = var.standard_tags
}

data "aws_iam_policy_document" "batch_service_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    effect = "Allow"

    principals {
      identifiers = [
        "sagemaker.amazonaws.com",
        "batch.amazonaws.com",
        "ecs-tasks.amazonaws.com",
        "s3.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "batch_service_role" {
  name = local.batch_service_role_name
  # Learn more by reading this Terraform documentation https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_compute_environment#argument-reference
  # Learn more by reading this AWS Batch documentation https://docs.aws.amazon.com/batch/latest/userguide/service_IAM_role.html
  description = "This role is passed to AWS Batch as a `service_role`. This allows AWS Batch to make calls to other AWS services on our behalf."

  assume_role_policy = data.aws_iam_policy_document.batch_service_role.json

  tags = var.standard_tags
}

data "aws_iam_policy_document" "ecs_instance_role" {
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

  assume_role_policy = data.aws_iam_policy_document.ecs_instance_role.json
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
}


/*
 Instance profile is a container for an IAM role. On console when we define role
 instance profile is generated but here we have to manually generate. The instance
 profile passes role info to the instance when it starts.
 Ref:
 https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html
*/
resource "aws_iam_instance_profile" "ecs_instance_role" {
  name = local.ecs_instance_role_name
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role_policy" "grant_ecs_access" {
  role   = aws_iam_role.ecs_execution_role.name
  policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

resource "aws_iam_role_policy_attachment" "batch_service_role" {
  role       = aws_iam_role.batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

# Attach policy to let Batch instances access S3 for input data, kms, and secrets
resource "aws_iam_role_policy_attachment" "batch_service_role_metaflow" {
  role       = aws_iam_role.batch_service_role.name
  policy_arn = var.metaflow_policy_arn
}

# If step functions are enabled, add permission to access dynamodb table
# https://github.com/Netflix/metaflow-tools/blob/master/aws/cloudformation/metaflow-cfn-template.yml#L1066
resource "aws_iam_role_policy" "step_functions_dynamodb" {
  count  = var.enable_step_functions ? 1 : 0
  name   = "Dynamodb"
  role   = aws_iam_role.batch_service_role.name
  policy = var.metaflow_step_functions_dynamodb_policy
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
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Attaches  policy to let Batch instances access KMS key for S3.
resource "aws_iam_role_policy_attachment" "batch_service_role_kms" {
  role       = aws_iam_role.batch_service_role.name
  policy_arn = var.s3_kms_policy_arn
}
