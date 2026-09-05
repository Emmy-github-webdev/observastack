output "key_id" {
  description = "KMS key ID."
  value       = aws_kms_key.observaStack_kms_key.key_id
}

output "key_arn" {
  description = "KMS key ARN."
  value       = aws_kms_key.observaStack_kms_key.arn
}

output "key_alias" {
  description = "KMS key alias."
  value       = aws_kms_alias.observaStack_kms_alias.name
}

output "key_alias_arn" {
  description = "KMS key alias ARN."
  value       = aws_kms_alias.observaStack_kms_alias.arn
}