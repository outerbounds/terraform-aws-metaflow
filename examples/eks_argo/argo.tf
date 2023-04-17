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
    "useStaticCredentials"   = false
    "artifactRepository" = {
      "s3" = {
        "bucket"      = module.metaflow-datastore.s3_bucket_name
        "keyFormat"   = "argo-artifacts/{{workflow.creationTimestamp.Y}}/{{workflow.creationTimestamp.m}}/{{workflow.creationTimestamp.d}}/{{workflow.name}}/{{pod.name}}"
        "region"      = data.aws_region.current.name
        "endpoint"    = "s3.amazonaws.com"
        "useSDKCreds" = true
        "insecure"    = false
      }
    }
  }

  argo_events_values = {
    "configs" = {
      "jetstream" = {
        "versions" = [
          {
            "configReloaderImage" = "natsio/nats-server-config-reloader:latest"
            "metricsExporterImage" = "natsio/prometheus-nats-exporter:latest"
            "natsImage" = "nats:latest"
            "startCommand" = "/nats-server"
            "version" = "latest"
          },
          {
            "configReloaderImage" = "natsio/nats-server-config-reloader:latest"
            "metricsExporterImage" = "natsio/prometheus-nats-exporter:latest"
            "natsImage" = "nats:2.9.15"
            "startCommand" = "/nats-server"
            "version" = "2.9.15"
          },
        ]
      }
    }
    "controller" = {
      "name" = "controller-manager"
      "rbac" = {
        "enabled" = true
        "namespaced" = false
      }
      "resources" = {
        "limits" = {
          "cpu" = "200m"
          "memory" = "192Mi"
        }
        "requests" = {
          "cpu" = "200m"
          "memory" = "192Mi"
        }
      }
      "serviceAccount" = {
        "create" = true
        "name" = "argo-events-events-controller-sa"
      }
    }
    "crds" = {
      "keep" = true
    }
    "extraObjects" = [
      {
        "apiVersion" = "v1"
        "kind" = "ServiceAccount"
        "metadata" = {
          "name" = "operate-workflow-sa"
          "namespace" = "default"
        }
      },
      {
        "apiVersion" = "rbac.authorization.k8s.io/v1"
        "kind" = "Role"
        "metadata" = {
          "name" = "operate-workflow-role"
          "namespace" = "default"
        }
        "rules" = [
          {
            "apiGroups" = [
              "argoproj.io",
            ]
            "resources" = [
              "workflows",
              "workflowtemplates",
              "cronworkflows",
              "clusterworkflowtemplates",
            ]
            "verbs" = [
              "*",
            ]
          },
        ]
      },
      {
        "apiVersion" = "rbac.authorization.k8s.io/v1"
        "kind" = "RoleBinding"
        "metadata" = {
          "name" = "operate-workflow-role-binding"
          "namespace" = "default"
        }
        "roleRef" = {
          "apiGroup" = "rbac.authorization.k8s.io"
          "kind" = "Role"
          "name" = "operate-workflow-role"
        }
        "subjects" = [
          {
            "kind" = "ServiceAccount"
            "name" = "operate-workflow-sa"
          },
        ]
      },
      {
        "apiVersion" = "rbac.authorization.k8s.io/v1"
        "kind" = "Role"
        "metadata" = {
          "name" = "view-events-role"
          "namespace" = "default"
        }
        "rules" = [
          {
            "apiGroups" = [
              "argoproj.io",
            ]
            "resources" = [
              "eventsources",
              "eventbuses",
              "sensors",
            ]
            "verbs" = [
              "get",
              "list",
              "watch",
            ]
          },
        ]
      },
      {
        "apiVersion" = "rbac.authorization.k8s.io/v1"
        "kind" = "RoleBinding"
        "metadata" = {
          "name" = "view-events-role-binding"
          "namespace" = "default"
        }
        "roleRef" = {
          "apiGroup" = "rbac.authorization.k8s.io"
          "kind" = "Role"
          "name" = "view-events-role"
        }
        "subjects" = [
          {
            "kind" = "ServiceAccount"
            "name" = "argo-workflows"
            "namespace" = "argo-workflows"
          },
        ]
      },
    ]
  }
}

resource "helm_release" "argo" {
  name = "argo"

  depends_on = [module.eks]

  repository   = "https://argoproj.github.io/argo-helm"
  chart        = "argo-workflows"
  namespace    = kubernetes_namespace.argo.metadata[0].name
  force_update = true

  values = [
    yamlencode(local.argo_values)
  ]
}


resource "kubernetes_namespace" "argo_events" {
  metadata {
    name = "argo-events"
  }
}

resource "helm_release" "argo_events" {
  name = "argo-events"

  depends_on = [helm_release.argo]

  repository   = "https://argoproj.github.io/argo-helm"
  chart        = "argo-events"
  namespace    = kubernetes_namespace.argo_events.metadata[0].name
  force_update = true

  values = [
    yamlencode(local.argo_events_values)
  ]
}


resource "helm_release" "argo_events_helper_chart" {
  name = "argo-events-helper-chart"

  depends_on = [helm_release.argo_events]

  chart        = "./argo-events-helper-chart"
  namespace    = kubernetes_namespace.argo_events.metadata[0].name
  force_update = true
}
