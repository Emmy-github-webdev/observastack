output "vpc_id" {
  description = "Development VPC ID."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Development private subnet IDs."
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "Development database subnet IDs."
  value       = module.vpc.database_subnet_ids
}

output "eks_cluster_name" {
  description = "Development EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Development EKS Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "rds_endpoint" {
  description = "Development PostgreSQL endpoint."
  value       = module.rds.endpoint
  sensitive   = true
}

output "rds_master_user_secret_arn" {
  description = "AWS-managed RDS master-user secret ARN."
  value       = module.rds.master_user_secret_arn
  sensitive   = true
}

output "redis_primary_endpoint" {
  description = "Development Redis primary endpoint."
  value       = module.redis.primary_endpoint_address
  sensitive   = true
}

output "observability_dashboard_name" {
  description = "Development CloudWatch observability dashboard name."
  value       = module.observability.dashboard_names
}

output "observability_log_groups" {
  description = "CloudWatch Log Group names managed by ObservaStack."
  value       = module.observability.log_group_names
}

output "observability_log_group_arns" {
  description = "CloudWatch Log Group ARNs managed by ObservaStack."
  value       = module.observability.log_group_arns
}

output "secret_arns" {
  description = "Application secret ARNs managed by the Secrets Manager module."
  value       = module.secrets.secret_arns
  sensitive   = true
}

output "ecr_repository_name" {
  description = "Shared ObservaStack ECR repository name."
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "Shared ObservaStack ECR repository URL."
  value       = module.ecr.repository_url
}