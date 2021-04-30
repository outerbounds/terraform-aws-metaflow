data "aws_iam_policy_document" "iam_s3_access_role" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [
        "ec2.amazonaws.com",
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com",
        "batch.amazonaws.com",
        "s3.amazonaws.com"
      ]
      type = "Service"
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "iam_s3_access_role" {
  name = "${var.resource_prefix}iam-role${var.resource_suffix}"
  # Read more about ECS' `task_role` and `execution_role` here https://stackoverflow.com/a/49947471
  description        = "This role is passed to AWS ECS' task definition as the `task_role`. This allows the running of the Metaflow Metadata Service to have the proper permissions to speak to other AWS resources."
  assume_role_policy = data.aws_iam_policy_document.iam_s3_access_role.json

  tags = var.standard_tags
}

data "aws_iam_policy_document" "kms_s3" {
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ReEncryptTo",
      "kms:ReEncryptFrom",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]

    resources = [
      aws_kms_key.s3.arn
    ]
  }
}

resource "aws_iam_policy" "kms_s3" {
  name        = "${var.resource_prefix}kms-s3${var.resource_suffix}"
  description = "Policy to allow access to the KMS key for encryption/decryption of Metaflow's S3 bucket. This bucket is used by Metaflow internally to store blobs such as input, output, artifacts and other data revolving around flows. It is not recommended to store things in this bucket that Metaflow does not track itself."

  policy = data.aws_iam_policy_document.kms_s3.json
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    sid = "ListObjectsInBucket"

    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_access" {
  name        = "${var.resource_prefix}s3-access${var.resource_suffix}"
  description = "Grants access to the Metaflow S3 bucket"

  policy = data.aws_iam_policy_document.s3_access.json
}

resource "aws_iam_role_policy_attachment" "grant_metaflow_s3_access" {
  role       = aws_iam_role.iam_s3_access_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}
