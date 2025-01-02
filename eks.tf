module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.6"
  count   = var.create_eks_cluster ? 1 : 0

  cluster_version = "1.31" # Specify the desired EKS version
  cluster_name    = local.eks_name
  vpc_id          = local.vpc_id
  subnet_ids      = local.subnet_ids
  enable_irsa     = true
  eks_managed_node_group_defaults = merge({
    ami_type  = "AL2023_x86_64_STANDARD"
    disk_size = 50
  }, var.node_group_defaults)

  eks_managed_node_groups = merge({
    metaflow_default = {
      desired_capacity = 2
      max_size         = 2
      min_size         = 1
      instance_type    = "m5.large"
  } }, var.node_groups)


  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  iam_role_additional_policies = length(var.node_group_iam_role_additional_policies) > 0 ? var.node_group_iam_role_additional_policies : {
    "default_node" = aws_iam_policy.default_node[0].arn,
    "autoscaler"   = aws_iam_policy.cluster_autoscaler[0].arn,
    # Allow SSM access to the machines incase direct access is needed
    "ssm" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  }

  tags = var.tags
}

resource "aws_iam_policy" "default_node" {
  count = var.create_eks_cluster && length(var.node_group_iam_role_additional_policies) == 0 ? 1 : 0

  name_prefix = "${local.resource_prefix}-default-node-policy${local.resource_suffix}"
  description = "Default policy for cluster ${local.resource_prefix}-eks${local.resource_suffix}"
  policy      = data.aws_iam_policy_document.default_node.json
}

data "aws_iam_policy_document" "default_node" {
  statement {
    sid    = "S3"
    effect = "Allow"

    actions = [
      "s3:*",
      "kms:*",
    ]

    resources = ["*"]
  }
}

data "aws_iam_role" "current_role" {
  name = element(split("/", data.aws_caller_identity.current.arn), 1)
}

resource "aws_eks_access_entry" "provider_cluster_admin" {
  count = var.create_eks_cluster ? 1 : 0

  cluster_name  = module.eks[0].cluster_name
  principal_arn = data.aws_iam_role.current_role.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "provider_cluster_admin" {
  count = var.create_eks_cluster ? 1 : 0

  depends_on    = [aws_eks_access_entry.provider_cluster_admin]
  cluster_name  = module.eks[0].cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_iam_role.current_role.arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  count = var.create_eks_cluster && length(var.node_group_iam_role_additional_policies) == 0 ? 1 : 0

  name_prefix = "${local.resource_prefix}-cluster-autoscaler${local.resource_suffix}"
  description = "EKS cluster-autoscaler policy for cluster ${local.eks_name}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler[0].json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  count = var.create_eks_cluster ? 1 : 0
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${local.eks_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

data "aws_eks_cluster" "cluster" {
  count = var.create_eks_cluster ? 1 : 0
  name  = module.eks[0].cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.create_eks_cluster ? 1 : 0
  name  = module.eks[0].cluster_name
}

module "metaflow_helm" {
  source = "./modules/services"

  kubernetes_cluster_host           = var.create_eks_cluster ? data.aws_eks_cluster.cluster[0].endpoint : ""
  kubernetes_cluster_ca_certificate = var.create_eks_cluster ? data.aws_eks_cluster.cluster[0].certificate_authority.0.data : ""
  kubernetes_token                  = var.create_eks_cluster ? data.aws_eks_cluster_auth.cluster[0].token : ""

  resource_name_prefix      = local.resource_prefix
  deploy_metaflow_service   = var.deploy_metaflow_services_in_eks
  metaflow_helm_values      = var.metaflow_helm_values
  cluster_name              = var.create_eks_cluster ? module.eks[0].cluster_name : ""
  region                    = data.aws_region.current.name
  deploy_cluster_autoscaler = var.deploy_cluster_autoscaler
  cluster_oidc_provider     = var.create_eks_cluster ? module.eks[0].oidc_provider : ""
  account_id                = data.aws_caller_identity.current.account_id

  metaflow_database = {
    database_name = local.database_name
    host          = element(split(":", local.rds_master_instance_endpoint), 0)
    user          = local.database_username
    password      = local.database_password
  }
}
