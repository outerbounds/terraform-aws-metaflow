resource "helm_release" "metaflow" {
  count = var.deploy_metaflow_service ? 1 : 0

  name              = "metaflow"
  chart             = "${path.module}/../../../metaflow-tools/charts/metaflow" # TODO: Change to the official chart
  namespace         = "${var.resource_name_prefix}-service"
  create_namespace  = true
  dependency_update = true

  values = [
    yamlencode(merge({
      "metaflow-service" = {
        metadatadb = {
          host     = var.metaflow_database.host
          name     = var.metaflow_database.database_name
          user     = var.metaflow_database.user
          password = var.metaflow_database.password
        }
      }
      "metaflow-ui" = {
        uiBackend = {
          metadatadb = {
            host     = var.metaflow_database.host
            name     = var.metaflow_database.database_name
            user     = var.metaflow_database.user
            password = var.metaflow_database.password
          }
          metaflowServiceURL = "http://metaflow-metaflow-service/api/metadata"
        }
        uiStatic = {
          metaflowUIBackendURL = "http://metaflow-metaflow-ui/api/"
        }
      }
    }, var.metaflow_helm_values))
  ]
}

locals {
  autoscaler_sa_name = "${var.cluster_name}-cluster-autoscaler"
}

resource "helm_release" "cluster_autoscaler" {
  count = var.deploy_cluster_autoscaler ? 1 : 0
  name  = "autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  values = [yamlencode(
    {
      "rbac" = {
        "serviceAccount" = {
          "annotations" = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
          }
          "name" = local.autoscaler_sa_name
        }
      }
    }
  )]

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

}

resource "aws_iam_role" "cluster_autoscaler" {
  name = "${var.cluster_name}-cluster-autoscaler"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${var.cluster_oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.cluster_oidc_provider}:sub" = "system:serviceaccount:kube-system:${local.autoscaler_sa_name}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "cluster_autoscaler" {
  role = aws_iam_role.cluster_autoscaler.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_ec2" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_eks" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_eks_worker" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
