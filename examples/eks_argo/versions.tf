terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Or a more recent version
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0" // Use a version that supports the correct syntax
    }
  }
}

provider "aws" {
  region = "us-west-2"
}
