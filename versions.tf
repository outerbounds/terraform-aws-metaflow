terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # grants us access to the new `aws_api_gateway_rest_api_policy` resource which allows us to more easily avoid
      # hard coding values and avoid self referential issues when attempting to get the `aws_api_gateway_rest_api`'s
      # id for writing the policy. Previously we wrote the policy inline which is the old style. We're jumping from `v3.7.0`
      # `v3.16.0` which is only a minor upgrade.
      version = ">= 3.38.0"
    }
  }
  required_version = ">= 0.13"
}
