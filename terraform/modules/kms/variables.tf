variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "description" {
  description = "Description of the KMS key."
  type        = string
  default     = "ObservaStack customer-managed encryption key."
}

variable "enable_key_rotation" {
  description = "Enable automatic KMS key rotation."
  type        = bool
  default     = true
}

variable "deletion_window_in_days" {
  description = "Number of days before a scheduled KMS key deletion takes effect."
  type        = number
  default     = 30
  #default = 0 # for testing purposes only

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "KMS deletion window must be between 7 and 30 days."
  }

  # for testing purposes only, we allow deletion_window_in_days to be 0, but in production, it should be between 7 and 30 days.
  # validation {
  #   condition     = var.deletion_window_in_days >= 0 && var.deletion_window_in_days <= 0
  #   error_message = "KMS deletion window must be between 7 and 30 days."
  # }
}

variable "additional_key_policy_statements" {
  description = "Additional KMS key policy statements."
  type        = list(any)
  default     = []
}

variable "tags" {
  description = "Additional resource tags."
  type        = map(string)
  default     = {}
}