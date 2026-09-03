module "vpc" {
  source = "../../modules/vpc"

  project_name = "observastack"
  environment = "dev"

  vpc_cidr = "10.10.0.0/16"

  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_vpc_endpoints = true
  enable_flow_logs     = true

  tags = {
    CostCenter = "observastack-dev"
  }
}