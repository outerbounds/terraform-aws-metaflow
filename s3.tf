resource "aws_s3_bucket" "elb_access_logs_bucket" {
  count = var.elb_access_logging_enabled || var.elb_connection_logging_enabled ? 1 : 0

  bucket        = local.lb_access_logs_bucket_name
  force_destroy = false
  tags          = var.tags
}

resource "aws_s3_bucket_policy" "elb_access_logs_bucket" {
  count = var.elb_access_logging_enabled || var.elb_connection_logging_enabled ? 1 : 0

  bucket = local.lb_access_logs_bucket_name
  policy = data.aws_iam_policy_document.elb_access_logs_bucket[0].json
}

resource "aws_s3_bucket_ownership_controls" "elb_access_logs_bucket" {
  count = var.elb_access_logging_enabled || var.elb_connection_logging_enabled ? 1 : 0

  bucket = local.lb_access_logs_bucket_name
  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  depends_on = [time_sleep.wait_for_aws_s3_bucket_settings]
}

resource "aws_s3_bucket_public_access_block" "elb_access_logs_bucket" {
  count = var.elb_access_logging_enabled || var.elb_connection_logging_enabled ? 1 : 0

  bucket                  = local.lb_access_logs_bucket_name
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "elb_access_logs_bucket" {
  count = var.elb_access_logging_enabled || var.elb_connection_logging_enabled ? 1 : 0

  bucket = local.lb_access_logs_bucket_name
  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "elb_access_logs_bucket" {
  count  = var.elb_access_logging_enabled || var.elb_connection_logging_enabled ? 1 : 0
  bucket = local.lb_access_logs_bucket_name

  versioning_configuration {
    status = "Enabled"
  }
}

resource "time_sleep" "wait_for_aws_s3_bucket_settings" {
  count = var.elb_access_logging_enabled || var.elb_connection_logging_enabled ? 1 : 0

  depends_on       = [aws_s3_bucket_public_access_block.elb_access_logs_bucket, aws_s3_bucket_policy.elb_access_logs_bucket]
  create_duration  = "60s"
  destroy_duration = "60s"
}

# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
data "aws_iam_policy_document" "elb_access_logs_bucket" {
  count = var.elb_access_logging_enabled || var.elb_connection_logging_enabled ? 1 : 0

  statement {
    sid = "ForceSSLOnlyAccess"
    actions = [
      "s3:*",
    ]
    effect = "Deny"
    resources = [
      "arn:aws:s3:::${local.lb_access_logs_bucket_name}",
      "arn:aws:s3:::${local.lb_access_logs_bucket_name}/*",
    ]

    condition {
      test = "Bool"
      values = [
        "false",
      ]
      variable = "aws:SecureTransport"
    }

    principals {
      identifiers = [
        "*",
      ]
      type = "*"
    }
  }

  statement {
    sid       = "Allow the AWS Elastic Load Balancing to put access logs"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.lb_access_logs_bucket_name}/AWSLogs/${data.aws_caller_identity.current.id}/*"]

    principals {
      type = var.region_available_before_2022 ? "AWS" : "Service"
      # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html#attach-bucket-policy
      identifiers = var.region_available_before_2022 ? [data.aws_elb_service_account.current.arn] : ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }
  }

  statement {
    sid       = "Restrict to AWS Elastic Load Balancing"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.lb_access_logs_bucket_name}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "ForAllValues:StringNotEquals"
      variable = "aws:PrincipalServiceNamesList"
      values   = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }
  }

  statement {
    sid    = "Deny any modification or removal of ELB access logs"
    effect = "Deny"
    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:PutLifecycleConfiguration"
    ]
    resources = [
      "arn:aws:s3:::${local.lb_access_logs_bucket_name}",
      "arn:aws:s3:::${local.lb_access_logs_bucket_name}/*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
