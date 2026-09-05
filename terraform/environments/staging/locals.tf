locals {
  common_tags = {
    Project     = "observastack"
    Environment = "staging"
    ManagedBy   = "Terraform"
    Owner       = "ObservaStack"
    CostCenter  = "observastack-staging"
    Criticality = "medium"
  }
}
