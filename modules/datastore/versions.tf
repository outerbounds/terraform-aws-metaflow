terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.38.0, < 4.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 0.13"
}
