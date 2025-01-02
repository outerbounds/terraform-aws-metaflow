terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.82"
    }
  }
  required_version = ">= 1.10"
}
