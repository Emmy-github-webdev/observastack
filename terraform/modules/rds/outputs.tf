output "db_instance_id" { value = aws_db_instance.db_instance.id }
output "db_instance_arn" { value = aws_db_instance.db_instance.arn }
output "db_instance_resource_id" { value = aws_db_instance.db_instance.resource_id }
output "endpoint" { value = aws_db_instance.db_instance.address }
output "port" { value = aws_db_instance.db_instance.port }
output "database_name" { value = aws_db_instance.db_instance.db_name }
output "security_group_id" { value = aws_security_group.db_security_group.id }
output "subnet_group_name" { value = aws_db_subnet_group.db_subnet_group.name }
output "parameter_group_name" { value = aws_db_parameter_group.db_parameter_group.name }

output "master_user_secret_arn" {
  value     = try(aws_db_instance.db_instance.master_user_secret[0].secret_arn, null)
  sensitive = true
}
