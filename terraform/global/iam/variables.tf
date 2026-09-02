variable "aws_region" {
  type        = string
  description = "AWS region for the IAM bootstrap."
  default     = "us-east-1"
}

variable "github_org" {
  type        = string
  description = "GitHub organization or user that owns the repository."
}

variable "github_repository" {
  type        = string
  description = "GitHub repository name, without owner."
  default     = "observastack"
}

variable "github_branch" {
  type        = string
  description = "Protected branch allowed to assume deployment roles."
  default     = "main"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID hosting the bootstrap roles."
  sensitive   = true
}

variable "role_prefix" {
  type        = string
  description = "Prefix for GitHub Actions IAM roles."
  default     = "observastack-github"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags."
  default     = {}
}
