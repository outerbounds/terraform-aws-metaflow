# helm_provider.tf
provider "helm" {
  kubernetes {
    host                   = var.kubernetes_cluster_host
    cluster_ca_certificate = base64decode(var.kubernetes_cluster_ca_certificate)
    token                  = var.kubernetes_token
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.82"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17"
    }
  }
}
