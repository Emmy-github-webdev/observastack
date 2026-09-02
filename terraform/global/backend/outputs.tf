output "bucket_name" {
  description = "Terraform state bucket name."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "bucket_arn" {
  description = "Terraform state bucket ARN."
  value       = aws_s3_bucket.terraform_state.arn
}

output "region" {
  description = "Terraform state bucket region."
  value       = var.aws_region
}
