locals {
  name_prefix = "${var.project_name}-global"

  key_alias = "alias/${local.name_prefix}-ecr"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = "global"
      ManagedBy   = "Terraform"
      Component   = "kms"
      Purpose     = "ecr-encryption"
      Repository  = "Emmy-github-webdev/observastack"
      Owner       = "ObservaStack"
    },
    var.tags
  )
}