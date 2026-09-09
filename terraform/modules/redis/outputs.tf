output "replication_group_id" {
  value = aws_elasticache_replication_group.observastack_elasticache_replication_group.id
}

output "replication_group_arn" {
  value = aws_elasticache_replication_group.observastack_elasticache_replication_group.arn
}

output "primary_endpoint_address" {
  value = aws_elasticache_replication_group.observastack_elasticache_replication_group.primary_endpoint_address
}

output "reader_endpoint_address" {
  value = aws_elasticache_replication_group.observastack_elasticache_replication_group.reader_endpoint_address
}

output "port" {
  value = aws_elasticache_replication_group.observastack_elasticache_replication_group.port
}

output "security_group_id" {
  value = aws_security_group.observastack_elasticache_security_group.id
}

output "subnet_group_name" {
  value = aws_elasticache_subnet_group.observastack_elasticache_subnet_group.name
}

output "parameter_group_name" {
  value = aws_elasticache_parameter_group.observastack_elasticache_parameter_group.name
}

output "cloudwatch_log_group_name" {
  value = try(aws_cloudwatch_log_group.redis[0].name, null)
}
