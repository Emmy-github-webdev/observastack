module "vpc" {
  source = "../../modules/vpc"

  project_name = "observastack"
  environment  = "dev"

  vpc_cidr = "10.10.0.0/16"

  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]

  s3_endpoint_bucket_arns = [
    "arn:aws:s3:::emmy-github-webdev-observastack"
  ]

  tags = local.common_tags
}

module "kms" {
  source = "../../modules/kms"

  project_name = "observastack"
  environment  = "dev"

  deletion_window_in_days = 7

  tags = local.common_tags
}