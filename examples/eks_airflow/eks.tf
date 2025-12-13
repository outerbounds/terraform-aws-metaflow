
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.2"

  cluster_name    = local.cluster_name
  cluster_version = "1.33"
  subnet_ids      = module.vpc.private_subnets
  enable_irsa     = true
  tags            = local.tags

  vpc_id = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    ami_type  = "AL2023_x86_64_STANDARD"
    disk_size = 100
  }


  eks_managed_node_groups = {
    main = {
      desired_capacity = 1
      max_capacity     = 5
      min_capacity     = 1

      instance_types = ["r5.large"]
      update_config = {
        max_unavailable_percentage = 50
      }
    }
  }

  iam_role_additional_policies = {
    default_node       = aws_iam_policy.default_node.arn
    cluster_autoscaler = aws_iam_policy.cluster_autoscaler.arn
  }
}

resource "aws_iam_policy" "default_node" {
  name_prefix = "${local.cluster_name}-default"
  description = "Default policy for cluster ${module.eks.cluster_id}"
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

resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = "cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
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
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_id}"
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
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
