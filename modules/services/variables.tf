variable "kubernetes_cluster_host" {
  description = "The Kubernetes cluster host"
  type        = string
  default     = ""
}

variable "kubernetes_token" {
  description = "The kube config token for the eks cluster"
  type        = string
  default     = ""
}

variable "resource_name_prefix" {
  description = "The prefix to use for all resources"
  type        = string
  default     = ""
}

variable "kubernetes_cluster_ca_certificate" {
  description = "The Kubernetes cluster CA certificate"
  type        = string
  default     = ""
}

variable "deploy_metaflow_service" {
  description = "Deploy the Metaflow service"
  type        = bool
  default     = true
}


variable "metaflow_database" {
  type = object({
    database_name = string
    host          = string
    user          = string
    password      = string
  })
  description = "Properties of the database that will be used to store metadata about Metaflow runs"
  default     = null
}

variable "metaflow_helm_values" {
  description = "Values set to the metaflow helm chart"
  type        = any
  default     = {}
}

variable "cluster_name" {
  description = "the name of the EKS cluster"
  type        = string
  default     = ""
}

variable "cluster_oidc_provider" {
  description = "The issuer to use for the cluster"
  type        = string
  default     = ""
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
  default     = ""
}

variable "deploy_cluster_autoscaler" {
  description = "Deploy the cluster autoscaler"
  type        = bool
  default     = true
}

variable "region" {
  description = "The region to deploy the cluster autoscaler"
  type        = string
}
