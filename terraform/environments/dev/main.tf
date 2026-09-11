module "vpc" {
  source = "../../modules/vpc"

  project_name = local.project_name
  environment  = local.environment

  vpc_cidr = "10.10.0.0/16"

  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]

  enable_nat_gateway       = true
  single_nat_gateway       = true
  enable_vpc_endpoints     = true
  enable_flow_logs         = true
  flow_logs_retention_days = 7

  tags = local.common_tags
}

module "kms" {
  source = "../../modules/kms"

  project_name            = local.project_name
  environment             = local.environment
  description             = "ObservaStack development customer-managed KMS key."
  deletion_window_in_days = 7

  tags = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  project_name = local.project_name
  environment  = local.environment

  tags = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  project_name = local.project_name
  environment  = local.environment

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

  cluster_log_retention_days = 7

  node_group_instance_types = [
    "t3.medium"
  ]

  node_group_capacity_type = "ON_DEMAND"

  node_group_min_size     = 1
  node_group_desired_size = 2
  node_group_max_size     = 3

  node_group_disk_size = 50

  tags = local.common_tags
}

module "rds" {
  source              = "../../modules/rds"
  vpc_id              = module.vpc.vpc_id
  project_name        = local.project_name
  environment         = local.environment
  kms_key_arn         = module.kms.key_arn
  database_subnet_ids = module.vpc.database_subnet_ids
  tags                = local.common_tags
}

module "redis" {
  source = "../../modules/redis"

  project_name     = local.project_name
  environment      = local.environment
  vpc_id           = module.vpc.vpc_id
  cache_subnet_ids = module.vpc.database_subnet_ids
  kms_key_arn      = module.kms.key_arn
  tags             = local.common_tags
}

module "secrets" {
  source = "../../modules/secrets"

  project_name = local.project_name
  environment  = local.environment
  kms_key_arn  = module.kms.key_arn

  recovery_window_in_days = 14

  secrets = {
    "applications/user-service" = {
      description = "User service credentials"
    }
    "applications/product-service" = {
      description = "Product service credentials"
    }
    "applications/order-service" = {
      description = "Order service credentials"
    }
    "applications/payment-service" = {
      description = "Payment service credentials"
    }
    "integrations/stripe" = {
      description = "Payment provider integration credentials"
    }
  }

  rds_master_user_secret_arn = module.rds.master_user_secret_arn
  redis_auth_secret_arn      = module.redis.auth_token

  tags = local.common_tags
}

# module "observability" {
#   source = "../../modules/observability"

#   project_name = local.project_name
#   environment  = local.environment

#   kms_key_arn        = module.kms.key_arn
#   log_retention_days = 7

#   create_alarms    = true
#   create_dashboard = true

#   tags = local.common_tags
# }