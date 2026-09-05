locals {
  common_tags = {
    Project     = "observastack"
    Environment = "production"
    ManagedBy   = "Terraform"
    Owner       = "ObservaStack"
    CostCenter  = "observastack-production"
    Criticality = "high"
  }
}
