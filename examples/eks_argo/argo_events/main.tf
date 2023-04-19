locals {
  argo_events_values = {
    "configs" = {
      "jetstream" = {
        "versions" = [
          {
            "configReloaderImage"  = "natsio/nats-server-config-reloader:latest"
            "metricsExporterImage" = "natsio/prometheus-nats-exporter:latest"
            "natsImage"            = "nats:latest"
            "startCommand"         = "/nats-server"
            "version"              = "latest"
          },
          {
            "configReloaderImage"  = "natsio/nats-server-config-reloader:latest"
            "metricsExporterImage" = "natsio/prometheus-nats-exporter:latest"
            "natsImage"            = "nats:2.9.15"
            "startCommand"         = "/nats-server"
            "version"              = "2.9.15"
          },
        ]
      }
    }
    "controller" = {
      "name" = "controller-manager"
      "rbac" = {
        "enabled"    = true
        "namespaced" = false
      }
      "resources" = {
        "limits" = {
          "cpu"    = "200m"
          "memory" = "192Mi"
        }
        "requests" = {
          "cpu"    = "200m"
          "memory" = "192Mi"
        }
      }
      "serviceAccount" = {
        "create" = true
        "name"   = "argo-events-events-controller-sa"
      }
    }
    "crds" = {
      "keep" = true
    }
    "extraObjects" = [
      {
        "apiVersion" = "v1"
        "kind"       = "ServiceAccount"
        "metadata" = {
          "name"      = "operate-workflow-sa"
          "namespace" = var.jobs_namespace
        }
      },
      {
        "apiVersion" = "rbac.authorization.k8s.io/v1"
        "kind"       = "Role"
        "metadata" = {
          "name"      = "operate-workflow-role"
          "namespace" = var.jobs_namespace
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
        "kind"       = "RoleBinding"
        "metadata" = {
          "name"      = "operate-workflow-role-binding"
          "namespace" = var.jobs_namespace
        }
        "roleRef" = {
          "apiGroup" = "rbac.authorization.k8s.io"
          "kind"     = "Role"
          "name"     = "operate-workflow-role"
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
        "kind"       = "Role"
        "metadata" = {
          "name"      = "view-events-role"
          "namespace" = var.jobs_namespace
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
        "kind"       = "RoleBinding"
        "metadata" = {
          "name"      = "view-events-role-binding"
          "namespace" = var.jobs_namespace
        }
        "roleRef" = {
          "apiGroup" = "rbac.authorization.k8s.io"
          "kind"     = "Role"
          "name"     = "view-events-role"
        }
        "subjects" = [
          {
            "kind"      = "ServiceAccount"
            "name"      = "argo-workflows"
            "namespace" = "argo-workflows"
          },
        ]
      },
    ]
  }
}

resource "kubernetes_namespace" "argo_events" {
  metadata {
    name = "argo-events"
  }
}

resource "helm_release" "argo_events" {
  name = "argo-events"

  repository   = "https://argoproj.github.io/argo-helm"
  chart        = "argo-events"
  namespace    = kubernetes_namespace.argo_events.metadata[0].name
  force_update = true

  values = [
    yamlencode(local.argo_events_values)
  ]
}


resource "helm_release" "argo_events_helper_chart" {
  # We define an EventBus and EventSource in this helper chart. This is one
  # of the cleaner workarounds for the chicken-egg problem with CR and CRD definitions
  # in "terraform plan". E.g. Terraform tries to validate the kind "EventBus" before it
  # has been created in the cluster, causing the validation to fail.
  #
  # Mega-thread here: https://github.com/hashicorp/terraform-provider-kubernetes/issues/1367
  name = "argo-events-helper-chart"

  depends_on = [helm_release.argo_events]

  chart        = "${path.module}/argo-events-helper-chart"
  namespace    = kubernetes_namespace.argo_events.metadata[0].name
  force_update = true

  set {
    name  = "jobsNamespace"
    value = var.jobs_namespace
  }
}

variable "jobs_namespace" {
  type = string
}
