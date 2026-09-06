output "repository_name" {
  description = "ECR repository name."
  value       = aws_ecr_repository.observastack_ecr.name
}

output "repository_arn" {
  description = "ECR repository ARN."
  value       = aws_ecr_repository.observastack_ecr.arn
}

output "repository_url" {
  description = "ECR repository URL."
  value       = aws_ecr_repository.observastack_ecr.repository_url
}

output "registry_id" {
  description = "AWS account ID hosting the ECR repository."
  value       = aws_ecr_repository.observastack_ecr.registry_id
}