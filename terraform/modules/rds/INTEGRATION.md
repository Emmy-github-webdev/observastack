# 6.7 RDS Integration

Environment roots should compose this module; they should not duplicate it.

```hcl
module "rds" {
  source = "../../modules/rds"

  project_name = "observastack"
  environment  = "dev"

  vpc_id              = module.vpc.vpc_id
  database_subnet_ids = module.vpc.database_subnet_ids
  kms_key_arn         = module.kms.key_arn

  engine_version   = "17.6"
  parameter_family = "postgres17"

  instance_class       = "db.t4g.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"

  multi_az = true

  backup_retention_period = 7
  backup_window           = "03:00-03:30"
  maintenance_window      = "sun:04:00-sun:04:30"

  deletion_protection = true
  skip_final_snapshot = false
  publicly_accessible = false

  # Supply the dedicated application/workload SG here.
  allowed_security_group_ids = []

  enable_performance_insights           = true
  performance_insights_retention_period = 7
}
```

Do not use the EKS cluster security group as a broad database trust boundary.
Add/use a dedicated workload/application SG in the platform composition.

6.9 should consume `module.rds.master_user_secret_arn`.
