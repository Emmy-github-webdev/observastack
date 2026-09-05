locals {
  name_prefix = "${var.project_name}-${var.environment}"

  key_alias = "alias/${local.name_prefix}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "kms"
    },
    var.tags
  )
}