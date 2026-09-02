output "github_oidc_provider_arn" {
  description = "GitHub Actions OIDC provider ARN."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "terraform_bootstrap_role_arn" {
  description = "IAM role used by the backend bootstrap workflow."
  value       = aws_iam_role.terraform_bootstrap.arn
}

output "terraform_plan_role_arn" {
  description = "IAM role used for Terraform plans."
  value       = aws_iam_role.terraform_plan.arn
}

output "terraform_apply_role_arn" {
  description = "IAM role used for Terraform applies."
  value       = aws_iam_role.terraform_apply.arn
}
