module "vpc" {
  source = "../../modules/vpc"

  project_name = "observastack"
  environment  = "staging"

  vpc_cidr = "10.20.0.0/16"

  availability_zones = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]
  s3_endpoint_bucket_arns = [
    "arn:aws:s3:::emmy-github-webdev-observastack"
  ]

  tags = local.common_tags
}

module "kms" {
  source = "../../modules/kms"

  project_name = "observastack"
  environment  = "staging"

  deletion_window_in_days = 14

  tags = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  project_name = "observastack"
  environment  = "staging"

  # create_eks_cluster_role     = true
  # create_eks_node_role        = true
  # create_load_balancer_role   = true
  # create_external_secrets_role = true
  # create_application_roles    = true

  application_names = [
    "user-service",
    "product-service",
    "order-service",
    "payment-service"
  ]

  tags = local.common_tags
}