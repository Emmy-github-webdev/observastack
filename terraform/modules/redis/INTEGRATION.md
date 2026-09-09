# 6.8 Redis Integration

Compose this module from the environment root.

```hcl
module "redis" {
  source = "../../modules/redis"

  project_name = "observastack"
  environment  = "dev"

  vpc_id          = module.vpc.vpc_id
  cache_subnet_ids = module.vpc.cache_subnet_ids

  kms_key_arn = module.kms.key_arn

  engine_version = "7.2"
  node_type      = "cache.t4g.micro"

  num_cache_clusters       = 2
  automatic_failover_enabled = true
  multi_az_enabled         = true

  snapshot_retention_limit = 7

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  # Supply only the dedicated application/workload security group.
  allowed_security_group_ids = []

  log_delivery_enabled = true
}
```

## Dependency contract

6.8 expects:
- VPC to expose private cache subnet IDs and VPC ID.
- KMS to expose the environment Redis encryption key ARN.
- Platform/EKS composition to provide a dedicated application/workload SG.

Do not use the EKS cluster SG as a broad Redis trust boundary.

## Secrets

If Redis AUTH is enabled, the token must be managed as a sensitive input. The
later Secrets work can standardize how application workloads receive Redis
connection credentials without exposing them in Kubernetes manifests.
