output "application_log_group_name" {
  description = "Application CloudWatch Log Group name."
  value       = try(aws_cloudwatch_log_group.application[0].name, null)
}

output "application_log_group_arn" {
  description = "Application CloudWatch Log Group ARN."
  value       = try(aws_cloudwatch_log_group.application[0].arn, null)
}

output "platform_log_group_name" {
  description = "Platform CloudWatch Log Group name."
  value       = try(aws_cloudwatch_log_group.platform[0].name, null)
}

output "platform_log_group_arn" {
  description = "Platform CloudWatch Log Group ARN."
  value       = try(aws_cloudwatch_log_group.platform[0].arn, null)
}

output "audit_log_group_name" {
  description = "Audit CloudWatch Log Group name."
  value       = try(aws_cloudwatch_log_group.audit[0].name, null)
}

output "audit_log_group_arn" {
  description = "Audit CloudWatch Log Group ARN."
  value       = try(aws_cloudwatch_log_group.audit[0].arn, null)
}

output "dashboard_names" {
  description = "CloudWatch dashboard names."
  value       = [aws_cloudwatch_dashboard.observastack_cloudwatch_dashboard[0].dashboard_name]
}

output "log_group_arns" {
  description = "Map of managed CloudWatch Log Group ARNs."
  value = {
    application = try(aws_cloudwatch_log_group.application[0].arn, null)
    platform    = try(aws_cloudwatch_log_group.platform[0].arn, null)
    audit       = try(aws_cloudwatch_log_group.audit[0].arn, null)
  }
}
