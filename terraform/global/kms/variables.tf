variable "project_name" {
  description = "Project name used for resource naming."
  type        = string

  default = "observastack"
}

variable "description" {
  description = "Description for the shared ObservaStack ECR KMS key."
  type        = string

  default = "ObservaStack shared customer-managed KMS key for ECR encryption."
}

variable "deletion_window_in_days" {
  description = "Number of days before the KMS key is permanently deleted after destruction."
  type        = number

  default = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "KMS deletion window must be between 7 and 30 days."
  }
}

variable "enable_key_rotation" {
  description = "Enable automatic annual KMS key rotation."
  type        = bool

  default = true
}

variable "tags" {
  description = "Additional tags applied to the shared KMS key."
  type        = map(string)

  default = {}
}