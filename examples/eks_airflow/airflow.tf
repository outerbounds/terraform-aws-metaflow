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


resource "kubernetes_namespace" "airflow" {
  metadata {
    name = "airflow"
  }
}

data "aws_region" "current" {}

variable "airflow_webserver_secret" {
  type    = string
  default = "mysupersecr3tv0lue"
}

# This secret is that the airflow webserver used to sign session cookies.
# https://airflow.apache.org/docs/helm-chart/stable/production-guide.html#webserver-secret-key
resource "kubernetes_secret" "airflow-webserver-secret" {
  metadata {
    name      = "airflow-webserver-secret"
    namespace = kubernetes_namespace.airflow.metadata[0].name
  }
  type = "Opaque"
  data = {
    webserver-secret-key = var.airflow_webserver_secret
  }
}


locals {
  airflow_values = {
    "executor"                     = "LocalExecutor"
    "defaultAirflowTag"            = "2.3.3"
    "airflowVersion"               = "2.3.3"
    "webserverSecretKeySecretName" = kubernetes_secret.airflow-webserver-secret.metadata[0].name
    "env" = [
      {
        "name"  = "AIRFLOW_CONN_AWS_DEFAULT"
        "value" = "aws://"
      },
      {
        "name"  = "AIRFLOW__LOGGING__REMOTE_LOGGING"
        "value" = "True"
      },
      {
        "name"  = "AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER"
        "value" = "s3://${module.metaflow-datastore.s3_bucket_name}/airflow-logs"
      },
      {
        "name"  = "AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID"
        "value" = "aws_default"
      }
    ]
  }
}

resource "helm_release" "airflow" {

  depends_on = [module.eks]

  name = "airflow-deployment"

  repository = "https://airflow.apache.org"
  chart      = "airflow"

  namespace = kubernetes_namespace.airflow.metadata[0].name

  timeout = 1200

  wait = false # Why set `wait=false`
  #: Read this (https://github.com/hashicorp/terraform-provider-helm/issues/683#issuecomment-830872443)
  # Short summary : If this is not set then airflow doesn't end up running migrations on the database. That makes the scheduler and other containers to keep waiting for migrations.

  values = [
    yamlencode(local.airflow_values)
  ]
}
