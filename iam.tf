data "aws_iam_policy_document" "batch_s3_task_role_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    effect = "Allow"

    principals {
      identifiers = [
        "ecs-tasks.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "batch_s3_task_role" {
  name = local.batch_s3_task_role_name

  description = "Role for AWS Batch to Access Amazon S3 [METAFLOW_ECS_S3_ACCESS_IAM_ROLE]"

  assume_role_policy = data.aws_iam_policy_document.batch_s3_task_role_assume_role.json

  tags = var.tags
}

data "aws_iam_policy_document" "custom_s3_list_batch" {
  statement {
    sid = "BucketAccessBatch"
    actions = [
      "s3:ListBucket"
    ]

    effect = "Allow"

    resources = [
      module.metaflow-datastore.s3_bucket_arn
    ]
  }
}

data "aws_iam_policy_document" "custom_s3_batch" {
  statement {
    sid = "ObjectAccessBatch"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    effect = "Allow"

    resources = [
      "${module.metaflow-datastore.s3_bucket_arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "s3_kms" {
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]

    resources = [
      module.metaflow-datastore.datastore_s3_bucket_kms_key_arn
    ]
  }
}

data "aws_iam_policy_document" "deny_presigned_batch" {
  statement {
    sid = "DenyPresignedBatch"
    actions = [
      "s3:*"
    ]

    effect = "Deny"

    resources = [
      "*",
    ]

    condition {
      test = "StringNotEquals"
      values = [
        "REST-HEADER"
      ]
      variable = "s3:authType"
    }
  }
}

data "aws_iam_policy_document" "allow_sagemaker" {
  statement {
    sid = "AllowSagemakerCreate"
    actions = [
      "sagemaker:CreateTrainingJob"
    ]

    effect = "Allow"

    resources = [
      "arn:${var.iam_partition}:sagemaker:${local.aws_region}:${local.aws_account_id}:training-job/*",
    ]
  }

  statement {
    sid = "AllowSagemakerDescribe"
    actions = [
      "sagemaker:DescribeTrainingJob"
    ]

    effect = "Allow"

    resources = [
      "arn:${var.iam_partition}:sagemaker:${local.aws_region}:${local.aws_account_id}:training-job/*",
    ]
  }

  statement {
    sid = "AllowSagemakerDeploy"
    actions = [
      "sagemaker:CreateModel",
      "sagemaker:CreateEndpointConfig",
      "sagemaker:CreateEndpoint",
      "sagemaker:DescribeModel",
      "sagemaker:DescribeEndpoint",
      "sagemaker:InvokeEndpoint"
    ]

    effect = "Allow"

    resources = [
      "arn:${var.iam_partition}:sagemaker:${local.aws_region}:${local.aws_account_id}:endpoint/*",
      "arn:${var.iam_partition}:sagemaker:${local.aws_region}:${local.aws_account_id}:model/*",
      "arn:${var.iam_partition}:sagemaker:${local.aws_region}:${local.aws_account_id}:endpoint-config/*",
    ]
  }
}

data "aws_iam_policy_document" "iam_pass_role" {
  statement {
    sid = "AllowPassRole"
    actions = [
      "iam:PassRole",
    ]

    effect = "Allow"

    resources = [
      "*"
    ]

    condition {
      test = "StringEquals"
      values = [
        "sagemaker.amazonaws.com"
      ]
      variable = "iam:PassedToService"
    }
  }
}

data "aws_iam_policy_document" "dynamodb" {
  statement {
    sid = "Items"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
    ]

    effect = "Allow"

    resources = [
      module.metaflow-step-functions.metaflow_step_functions_dynamodb_table_arn
    ]
  }
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    sid = "AllowPutLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    effect = "Allow"

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "grant_custom_s3_list_batch" {
  name   = "s3_list"
  role   = aws_iam_role.batch_s3_task_role.name
  policy = data.aws_iam_policy_document.custom_s3_list_batch.json
}

resource "aws_iam_role_policy" "grant_custom_s3_batch" {
  name   = "custom_s3"
  role   = aws_iam_role.batch_s3_task_role.name
  policy = data.aws_iam_policy_document.custom_s3_batch.json
}

resource "aws_iam_role_policy" "grant_s3_kms" {
  name   = "s3_kms"
  role   = aws_iam_role.batch_s3_task_role.name
  policy = data.aws_iam_policy_document.s3_kms.json
}

resource "aws_iam_role_policy" "grant_deny_presigned_batch" {
  name   = "deny_presigned"
  role   = aws_iam_role.batch_s3_task_role.name
  policy = data.aws_iam_policy_document.deny_presigned_batch.json
}

resource "aws_iam_role_policy" "grant_allow_sagemaker" {
  name   = "sagemaker"
  role   = aws_iam_role.batch_s3_task_role.name
  policy = data.aws_iam_policy_document.allow_sagemaker.json
}

resource "aws_iam_role_policy" "grant_iam_pass_role" {
  name   = "iam_pass_role"
  role   = aws_iam_role.batch_s3_task_role.name
  policy = data.aws_iam_policy_document.iam_pass_role.json
}

resource "aws_iam_role_policy" "grant_dynamodb" {
  count  = var.enable_step_functions ? 1 : 0
  name   = "dynamodb"
  role   = aws_iam_role.batch_s3_task_role.name
  policy = data.aws_iam_policy_document.dynamodb.json
}

resource "aws_iam_role_policy" "grant_cloudwatch" {
  name   = "cloudwatch"
  role   = aws_iam_role.batch_s3_task_role.name
  policy = data.aws_iam_policy_document.cloudwatch.json
}

####################
# Custom S3 Access #
####################

# Wildcard for s3 actions to allow for other actions in the future that aren't needed currently
data "aws_iam_policy_document" "custom_s3_batch" {
  statement {
    sid = "ObjectAccessBatch"
    actions = [
      "s3:*"
    ]

    effect = "Allow"

    # Needs other buckets besides what specified in the batch, ecs execution, and ecs instance permissions
    resources = setunion([
      "${module.metaflow-datastore.s3_bucket_arn}/*",
      "${module.metaflow-datastore.s3_bucket_arn}",
      ],[for bucket in s3_access_buckets :
      "arn:aws:s3:::${bucket}"
      ], [for bucket in s3_access_buckets :
      "arn:aws:s3:::${bucket}/*"
      ])
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

######################################
# Athena Table Creation and Querying #
######################################

resource "aws_iam_role_policy_attachment" "metaflow_athena_permissions" {
  role       = aws_iam_role.batch_s3_task_role.name
  policy_arn = aws_iam_policy.metaflow_athena_permissions.arn
  }


resource "aws_iam_policy" "metaflow_athena_permissions" {
  name        = "metaflow-athena-permissions"
  description = "Policy to allow Metaflow to read and write to AWS Athena."
  policy      = data.aws_iam_policy_document.metaflow_athena_permissions.json
}

data "aws_iam_policy_document" "metaflow_athena_permissions" {

  statement {
    sid = "AthenaStartGetStopQuery"
    effect = "Allow"
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:StopQueryExecution",
      "athena:GetQueryRuntimeStatistics"
    ]
    resources = [
      "arn:aws:athena:${local.aws_region}:${local.aws_account_id}:workgroup/*"
      ]
  }

  statement {
    sid = "AthenaGetDataCatalog"
    effect = "Allow"
    actions = [
      "athena:GetDataCatalog"
    ]
    resources = [
      "arn:aws:athena:${local.aws_region}:${local.aws_account_id}:datacatalog/AwsDataCatalog"
      ]
  }

  statement {
    sid = "GlueBatch"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition",
      "glue:BatchCreatePartition"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid = "CreateGlueTables"
    effect = "Allow"
    actions = [
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:DeleteTable"    
    ]
    resources = [
      # "arn:aws:glue:us-east-2:334308037886:catalog",
      # "arn:aws:glue:us-east-2:334308037886:database/*-ds-*",
      # "arn:aws:glue:us-east-2:334308037886:table/*-ds-*/*"    
      "arn:aws:glue:us-east-2:${aws_account_id}:catalog",
      "arn:aws:glue:us-east-2:${aws_account_id}:database/${glue_database}",
      "arn:aws:glue:us-east-2:${aws_account_id}:table/${glue_database}/*"    
    ]
  }


  # statement {
  #   sid     = "AthenaListDataSourceBuckets"
  #   actions = ["s3:ListBucket"]
  #   resources = [
  #     for source_bucket in var.athena_source_buckets :
  #     "arn:aws:s3:::${source_bucket}"
  #   ]


  # }
  # statement {
  #   sid     = "AthenaGetSourceBucketData"
  #   actions = ["s3:GetObject"]
  #   resources = [
  #     for source_bucket in var.athena_source_buckets :
  #     "arn:aws:s3:::${source_bucket}/*"
  #   ]
  # }

  statement {
    sid = "AthenaGetResultsBucket"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${athena_query_bucket}"
    ]
  }

  statement {
    sid = "AthenaReadWriteResultsBucket"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
      "s3:PutObject",
      "s3:ListMultipartUploadParts",
      "s3:DeleteObject" # See "Note" in noctua::dbGetQuery docs
    ]
    resources = [
      "arn:aws:s3:::${athena_query_bucket}/*"
    ]
  }
}