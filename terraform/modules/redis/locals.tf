locals {
  name_prefix       = "${var.project_name}-${var.environment}"
  replication_group = "${local.name_prefix}-redis"

  common_tags = merge({
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Component   = "redis"
  }, var.tags)
}
