locals {
  name_prefix          = "${var.project_name}-${var.environment}"
  identifier           = "${local.name_prefix}-postgres"
  subnet_group_name    = "${local.name_prefix}-rds-subnet-group"
  parameter_group_name = "${local.name_prefix}-postgres-params"

  common_tags = merge({
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Component   = "rds"
  }, var.tags)
}
