locals {
  common_tags = merge(
    {
      Project    = var.project_name
      ManagedBy  = "Terraform"
      Component  = "ecr"
      Repository = var.repository_name
    },
    var.tags
  )
}