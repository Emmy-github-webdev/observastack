resource "aws_elasticache_subnet_group" "observastack_elasticache_subnet_group" {
  name       = "${local.name_prefix}-redis-subnet-group"
  subnet_ids = var.cache_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-redis-subnet-group"
  })
}

resource "aws_security_group" "observastack_elasticache_security_group" {
  name        = "${local.name_prefix}-redis"
  description = "Security group for ObservaStack Redis."
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_security_group_ids
    content {
      description     = "Redis from approved application security group."
      protocol        = "tcp"
      from_port       = var.port
      to_port         = var.port
      security_groups = [ingress.value]
    }
  }

  egress {
    description = "Allow Redis egress."
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-redis"
  })
}

resource "aws_elasticache_parameter_group" "observastack_elasticache_parameter_group" {
  name   = "${local.name_prefix}-redis-params"
  family = var.parameter_group_family

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-redis-params"
  })
}

resource "aws_cloudwatch_log_group" "redis" {
  count = var.log_delivery_enabled ? 1 : 0

  name              = coalesce(var.log_group_name, "/aws/elasticache/${local.replication_group}")
  retention_in_days = var.environment == "production" ? 90 : var.environment == "staging" ? 30 : 7

  tags = merge(local.common_tags, {
    Name = coalesce(var.log_group_name, "/aws/elasticache/${local.replication_group}")
  })
}

resource "aws_elasticache_replication_group" "observastack_elasticache_replication_group" {
  replication_group_id = local.replication_group
  description          = "ObservaStack Redis data/cache tier."

  engine         = "redis"
  engine_version = var.engine_version
  node_type      = var.node_type
  port           = var.port

  num_cache_clusters      = var.num_cache_clusters
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled        = var.multi_az_enabled

  subnet_group_name  = aws_elasticache_subnet_group.observastack_elasticache_subnet_group.name
  security_group_ids = [aws_security_group.observastack_elasticache_security_group.id]
  parameter_group_name = aws_elasticache_parameter_group.observastack_elasticache_parameter_group.name

  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  kms_key_id                  = var.kms_key_arn

  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = var.auth_token

  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window
  maintenance_window       = var.maintenance_window
  apply_immediately        = var.apply_immediately

  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_enabled ? ["engine-log", "slow-log"] : []
    content {
      destination      = aws_cloudwatch_log_group.redis[0].name
      destination_type = "cloudwatch-logs"
      log_format       = var.log_delivery_log_format
      log_type         = log_delivery_configuration.value
    }
  }

  tags = merge(local.common_tags, {
    Name = local.replication_group
  })
}
