locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge({
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Component   = "observability"
  }, var.tags)

  log_groups = {
    application = "/observastack/${var.environment}/application"
    platform    = "/observastack/${var.environment}/platform"
    audit       = "/observastack/${var.environment}/audit"
  }
}
