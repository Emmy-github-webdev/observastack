locals {
  common_tags = {
    Project     = "observastack"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "ObservaStack"
    CostCenter  = "observastack-dev"
    Criticality = "low"
  }
}