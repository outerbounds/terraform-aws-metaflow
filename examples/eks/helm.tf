provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

resource "helm_release" "cluster_autoscaler" {
  name = "autoscaler"

  depends_on = [module.eks]

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  set {
    name  = "autoDiscovery.clusterName"
    value = local.cluster_name
  }

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }
}


resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argo"
  }
}

resource "kubernetes_default_service_account" "default" {
  metadata {
    namespace = kubernetes_namespace.argo.metadata[0].name
  }
}

data "aws_region" "current" {}

locals {
  argo_values = {
    "server" = {
      "extraArgs" = ["--auth-mode=server"]
    }
    "workflow" = {
      "serviceAccount" = {
        "create" = true
      }
    }
    "controller" = {
      "containerRuntimeExecutor" = "emissary"
    }
    "useDefaultArtifactRepo" = true
    "useStaticCredentials" = false
    "artifactRepository" = {
      "s3" = {
        "bucket" = module.metaflow-datastore.s3_bucket_name
        "keyFormat" = "argo-artifacts/{{workflow.creationTimestamp.Y}}/{{workflow.creationTimestamp.m}}/{{workflow.creationTimestamp.d}}/{{workflow.name}}/{{pod.name}}"
        "region" = data.aws_region.current.name
        "endpoint" = "s3.amazonaws.com"
        "useSDKCreds" = true
        "insecure" = false
      }
    }
  }
}

resource "helm_release" "argo" {
  name = "argo"

  depends_on = [module.eks]

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-workflows"
  namespace  = kubernetes_namespace.argo.metadata[0].name
  force_update = true

  values = [
    yamlencode(local.argo_values)
  ]
}
