locals {
  name_prefix = "${var.project_name}-${var.environment}"

  cluster_name = "${local.name_prefix}-eks"

  node_group_name = "${local.name_prefix}-system"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "eks"
    },
    var.tags
  )
}