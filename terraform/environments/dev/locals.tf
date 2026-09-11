locals {
  project_name = "observastack"
  environment  = "dev"
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Repository  = "Emmy-github-webdev/observastack"
    Owner       = "ObservaStack"
  }
}