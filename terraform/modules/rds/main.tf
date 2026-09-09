resource "aws_db_subnet_group" "db_subnet_group" {
  name       = local.subnet_group_name
  subnet_ids = var.database_subnet_ids
  tags       = merge(local.common_tags, { Name = local.subnet_group_name })
}

resource "aws_security_group" "db_security_group" {
  name        = "${local.name_prefix}-rds"
  description = "Security group for ObservaStack PostgreSQL RDS."
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_security_group_ids
    content {
      description     = "PostgreSQL from approved application security group."
      protocol        = "tcp"
      from_port       = var.database_port
      to_port         = var.database_port
      security_groups = [ingress.value]
    }
  }

  egress {
    description = "Allow database egress."
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-rds" })
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = local.parameter_group_name
  family = var.parameter_family

  parameter {
    name         = "rds.force_ssl"
    value        = var.force_ssl ? "1" : "0"
    apply_method = "pending-reboot"
  }

  tags = merge(local.common_tags, { Name = local.parameter_group_name })
}

resource "aws_db_instance" "db_instance" {
  identifier = local.identifier

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  db_name                     = var.database_name
  username                    = var.master_username
  manage_master_user_password = var.manage_master_user_password

  port                   = var.database_port
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name

  multi_az            = var.multi_az
  publicly_accessible = var.publicly_accessible

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  auto_minor_version_upgrade = true
  deletion_protection        = var.deletion_protection
  delete_automated_backups   = false

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier
  apply_immediately         = var.apply_immediately

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_kms_key_id       = var.enable_performance_insights ? var.kms_key_arn : null
  performance_insights_retention_period = var.enable_performance_insights ? var.performance_insights_retention_period : null

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? var.monitoring_role_arn : null

  tags = merge(local.common_tags, { Name = local.identifier })
}
