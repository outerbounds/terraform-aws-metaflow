terraform {
  required_version = ">= 1.4"

  required_providers {
    aws    = ">= 3.54.0, <6.0.0"
    random = ">= 2.1"
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6, < 3.0"
    }
  }
}
