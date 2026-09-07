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

  # deletion_window_in_days = 7
  deletion_window_in_days = 0 # for testing purposes only

  tags = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  project_name = "observastack"
  environment  = "dev"

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

module "eks" {
  source = "../../modules/eks"

  project_name = "observastack"
  environment  = "dev"

  kubernetes_version = "1.35"

  vpc_id = module.vpc.vpc_id

  private_subnet_ids = module.vpc.private_subnet_ids

  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_role_arn

  vpc_cni_role_arn = module.iam.vpc_cni_role_arn
  ebs_csi_role_arn = module.iam.ebs_csi_role_arn

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  cluster_encryption_kms_key_arn = module.kms.key_arn
  cluster_log_kms_key_arn        = module.kms.key_arn

  # cluster_log_retention_days = 7
  cluster_log_retention_days = 0 # for testing purposes only

  node_group_instance_types = [
    "t3.medium"
  ]

  node_group_capacity_type = "ON_DEMAND"

  node_group_min_size     = 2
  node_group_desired_size = 2
  node_group_max_size     = 4

  node_group_disk_size = 50

  tags = local.common_tags
}