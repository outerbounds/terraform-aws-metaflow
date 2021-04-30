resource "aws_kms_key" "s3" {
  description = "This key is used to encrypt and decrypt the S3 bucket used to store blobs."

  tags = var.standard_tags
}

resource "aws_kms_key" "rds" {
  description = "This key is used to encrypt and decrypt the RDS database used to store flow execution data."

  tags = var.standard_tags
}