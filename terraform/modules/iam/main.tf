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