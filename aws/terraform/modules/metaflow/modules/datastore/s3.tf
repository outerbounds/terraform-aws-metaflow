data "aws_iam_policy_document" "this" {
  statement {
    sid = "allow-ecs-instance"

    effect = "Allow"

    principals {
      identifiers = [
        var.ecs_instance_role_arn
      ]
      type = "AWS"
    }

    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::${local.s3_bucket_name}",
      "arn:aws:s3:::${local.s3_bucket_name}/*"
    ]
  }

  statement {
    sid = "allow-ecs-execution"

    effect = "Allow"

    principals {
      identifiers = [
        var.ecs_execution_role_arn
      ]
      type = "AWS"
    }

    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::${local.s3_bucket_name}",
      "arn:aws:s3:::${local.s3_bucket_name}/*"
    ]
  }

  statement {
    sid = "allow-batch-service"

    effect = "Allow"

    principals {
      identifiers = [
        var.aws_batch_service_role_arn
      ]
      type = "AWS"
    }

    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::${local.s3_bucket_name}",
      "arn:aws:s3:::${local.s3_bucket_name}/*"
    ]
  }
}

resource "aws_s3_bucket" "this" {
  bucket = local.s3_bucket_name
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  policy = data.aws_iam_policy_document.this.json

  tags = merge(
    var.standard_tags,
    {
      Metaflow = "true"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
