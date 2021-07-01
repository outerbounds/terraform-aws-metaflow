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
