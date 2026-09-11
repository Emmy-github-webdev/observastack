output "key_id" {
  description = "ID of the shared ECR KMS key."
  value       = aws_kms_key.ecr.key_id
}

output "key_arn" {
  description = "ARN of the shared ECR KMS key."
  value       = aws_kms_key.ecr.arn
}

output "key_alias" {
  description = "Alias of the shared ECR KMS key."
  value       = aws_kms_alias.ecr.name
}

output "key_alias_arn" {
  description = "ARN of the shared ECR KMS alias."
  value       = aws_kms_alias.ecr.arn
}