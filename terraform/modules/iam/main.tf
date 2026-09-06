##############################
# EKS Cluster IAM Role
##############################

data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    sid    = "AllowEKSServiceAssumeRole"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "eks_cluster" {
  count = var.create_eks_cluster_role ? 1 : 0

  name = "${local.name_prefix}-eks-cluster-role"

  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name      = "${local.name_prefix}-eks-cluster-role"
      Component = "eks"
      Purpose   = "cluster"
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count = var.create_eks_cluster_role ? 1 : 0

  role       = aws_iam_role.eks_cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

###############################
# EKS Node IAM Role 
###############################
data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    sid    = "AllowEC2ServiceAssumeRole"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "eks_node" {
  count = var.create_eks_node_role ? 1 : 0

  name = "${local.name_prefix}-eks-node-role"

  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name      = "${local.name_prefix}-eks-node-role"
      Component = "eks"
      Purpose   = "worker-node"
    }
  )
}

##########################################
# Attach the standard EKS node permissions
##########################################

resource "aws_iam_role_policy_attachment" "eks_node_worker" {
  count = var.create_eks_node_role ? 1 : 0

  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_ecr" {
  count = var.create_eks_node_role ? 1 : 0

  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_cni" {
  count = var.create_eks_node_role ? 1 : 0

  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

#######################################
# Load Balancer Controller IAM Role
#######################################
data "aws_iam_policy_document" "load_balancer_assume_role" {
  count = var.create_load_balancer_role ? 1 : 0

  statement {
    sid    = "AllowEKSPodIdentity"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "load_balancer" {
  count = var.create_load_balancer_role ? 1 : 0

  name = "${local.name_prefix}-aws-load-balancer-controller"

  assume_role_policy = data.aws_iam_policy_document.load_balancer_assume_role[0].json

  tags = merge(
    local.common_tags,
    {
      Name      = "${local.name_prefix}-aws-load-balancer-controller"
      Component = "eks"
      Purpose   = "aws-load-balancer-controller"
    }
  )
}

####################################
# External Secrets IAM Role
####################################

data "aws_iam_policy_document" "external_secrets_assume_role" {
  count = var.create_external_secrets_role ? 1 : 0

  statement {
    sid    = "AllowEKSPodIdentity"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "external_secrets" {
  count = var.create_external_secrets_role ? 1 : 0

  name = "${local.name_prefix}-external-secrets"

  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume_role[0].json

  tags = merge(
    local.common_tags,
    {
      Name      = "${local.name_prefix}-external-secrets"
      Component = "secrets"
      Purpose   = "external-secrets"
    }
  )
}

data "aws_iam_policy_document" "external_secrets" {
  count = var.create_external_secrets_role ? 1 : 0

  statement {
    sid    = "ReadObservaStackSecrets"
    effect = "Allow"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      "arn:aws:secretsmanager:*:*:secret:observastack/${var.environment}/*"
    ]
  }
}

resource "aws_iam_role_policy" "external_secrets" {
  count = var.create_external_secrets_role ? 1 : 0

  name = "${local.name_prefix}-external-secrets-policy"
  role = aws_iam_role.external_secrets[0].id

  policy = data.aws_iam_policy_document.external_secrets[0].json
}