output "secret_arns" {
  description = "Map of managed secret names to ARNs."
  value       = { for name, secret in aws_secretsmanager_secret.observastack_secret : name => secret.arn }
}

output "secret_ids" {
  description = "Map of managed secret names to Secrets Manager IDs/ARNs."
  value       = { for name, secret in aws_secretsmanager_secret.observastack_secret : name => secret.id }
}

output "secret_names" {
  description = "Map of managed secret keys to fully-qualified Secrets Manager names."
  value       = { for name, secret in aws_secretsmanager_secret.observastack_secret : name => secret.name }
}

output "secret_kms_key_ids" {
  description = "Map of managed secret keys to the KMS key IDs used by Secrets Manager."
  value       = { for name, secret in aws_secretsmanager_secret.observastack_secret : name => secret.kms_key_id }
}

output "rds_master_user_secret_arn" {
  description = "RDS-managed master user secret ARN passed into this module, if supplied."
  value       = var.rds_master_user_secret_arn
}

output "redis_auth_secret_arn" {
  description = "Existing Redis authentication secret ARN passed into this module, if supplied."
  value       = var.redis_auth_secret_arn
}
