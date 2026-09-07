locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "iam"
    },
    var.tags
  )
  
  pod_identity_trust_actions = [
    "sts:AssumeRole",
    "sts:TagSession"
  ]

  application_role_names = {
    for application in var.application_names :
    application => "${local.name_prefix}-${application}"
  }
}