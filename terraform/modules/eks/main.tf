#####################################
## EKS Cluster
#####################################

resource "aws_eks_cluster" "observastack_eks_cluster" {
  name     = local.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids = var.private_subnet_ids

    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
  }

  enabled_cluster_log_types = var.cluster_enabled_log_types

  encryption_config {
    provider {
      key_arn = var.cluster_encryption_kms_key_arn
    }

    resources = [
      "secrets"
    ]
  }

  tags = merge(
    local.common_tags,
    {
      Name = local.cluster_name
    }
  )

  depends_on = [
    var.cluster_role_arn
  ]
}

#####################################
## log group
#####################################
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_days
  kms_key_id        = var.cluster_log_kms_key_arn

  tags = merge(
    local.common_tags,
    {
      Name      = "/aws/eks/${local.cluster_name}/cluster"
      Component = "eks-logging"
    }
  )
}

##################################
# Cluster security group
##################################
resource "aws_security_group" "cluster" {
  name        = "${local.cluster_name}-cluster"
  description = "Security group for the ObservaStack EKS control plane."
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.cluster_name}-cluster"
    }
  )
}


##################################
# Managed node group
##################################
resource "aws_eks_node_group" "system" {
  cluster_name    = aws_eks_cluster.observastack_eks_cluster.name
  node_group_name = local.node_group_name
  node_role_arn   = var.node_role_arn

  subnet_ids = var.private_subnet_ids

  capacity_type  = var.node_group_capacity_type
  instance_types = var.node_group_instance_types

  disk_size = var.node_group_disk_size

  scaling_config {
    min_size     = var.node_group_min_size
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
  }

  labels = merge(
    {
      "observastack.io/node-group" = "system"
    },
    var.node_group_labels
  )

  update_config {
    max_unavailable = 1
  }

  tags = merge(
    local.common_tags,
    {
      Name = local.node_group_name
    }
  )

  depends_on = [
    aws_eks_cluster.observastack_eks_cluster
  ]
}


##################################
# EKS managed add-ons
##################################
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.observastack_eks_cluster.name
  addon_name   = "vpc-cni"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  pod_identity_association {
    role_arn        = var.vpc_cni_role_arn
    service_account = "aws-node"
  }

  tags = merge(local.common_tags, { Component = "vpc-cni" })

  depends_on = [aws_eks_addon.pod_identity_agent]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.observastack_eks_cluster.name
  addon_name   = "coredns"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = local.common_tags

  depends_on = [
    aws_eks_node_group.system
  ]
}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = aws_eks_cluster.observastack_eks_cluster.name
  addon_name   = "eks-pod-identity-agent"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(local.common_tags, { Component = "pod-identity-agent" })

  depends_on = [aws_eks_node_group.system]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.observastack_eks_cluster.name
  addon_name   = "kube-proxy"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = local.common_tags

  depends_on = [
    aws_eks_node_group.system
  ]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.observastack_eks_cluster.name
  addon_name   = "aws-ebs-csi-driver"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  pod_identity_association {
    role_arn        = var.ebs_csi_role_arn
    service_account = "ebs-csi-controller-sa"
  }

  tags = merge(local.common_tags, { Component = "ebs-csi" })

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_eks_addon.vpc_cni
  ]
}



##################################
# EKS Access Entries
##################################
resource "aws_eks_access_entry" "observastack_eks_access_entry" {
  for_each = var.access_entries

  cluster_name  = aws_eks_cluster.observastack_eks_cluster.name
  principal_arn = each.value.principal_arn

  depends_on = [
    aws_eks_cluster.observastack_eks_cluster
  ]
}

resource "aws_eks_access_policy_association" "observastack_" {
  for_each = {
    for item in flatten([
      for name, entry in var.access_entries : [
        for policy_arn in entry.policy_arns : {
          key           = "${name}:${policy_arn}"
          principal_arn = entry.principal_arn
          policy_arn    = policy_arn
        }
      ]
    ]) : item.key => item
  }

  cluster_name  = aws_eks_cluster.observastack_eks_cluster.name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope { type = "cluster" }

  depends_on = [aws_eks_access_entry.observastack_eks_access_entry]
}