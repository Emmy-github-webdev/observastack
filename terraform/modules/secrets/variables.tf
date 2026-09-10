variable "project_name" {
  description = "Project name used in secret names and tags."
  type        = string

  validation {
    condition     = trimspace(var.project_name) != ""
    error_message = "project_name must not be empty."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "kms_key_arn" {
  description = "Customer-managed KMS key ARN used to encrypt secret values."
  type        = string

  validation {
    condition     = trimspace(var.kms_key_arn) != ""
    error_message = "kms_key_arn must not be empty."
  }
}

variable "recovery_window_in_days" {
  description = "Default recovery window for managed secrets. AWS supports 0 or 7-30 days."
  type        = number
  default     = 30

  validation {
    condition     = var.recovery_window_in_days == 0 || (var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30)
    error_message = "recovery_window_in_days must be 0 or between 7 and 30 days."
  }
}

variable "secrets" {
  description = <<-EOT
    Map of application/platform secret definitions. This module intentionally manages
    secret metadata only; it does not accept plaintext secret values so credentials
    are not written into Terraform configuration or state.
  EOT
  type = map(object({
    description             = optional(string, "ObservaStack managed secret.")
    recovery_window_in_days = optional(number)
    kms_key_arn             = optional(string)
    tags                    = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for name, secret in var.secrets :
      length(name) >= 1 && length(name) <= 512 && can(regex("^[A-Za-z0-9/_+=.@-]+$", name))
    ])
    error_message = "Secret map keys must contain only AWS Secrets Manager-supported characters and be 1-512 characters long."
  }

  validation {
    condition = alltrue([
      for name, secret in var.secrets :
      try(secret.recovery_window_in_days, var.recovery_window_in_days) == 0 ||
      (try(secret.recovery_window_in_days, var.recovery_window_in_days) >= 7 && try(secret.recovery_window_in_days, var.recovery_window_in_days) <= 30)
    ])
    error_message = "Each secret recovery_window_in_days must be 0 or between 7 and 30 days."
  }
}

variable "secret_resource_policies" {
  description = "Optional JSON resource policies keyed by secret map key. Use least privilege; omit unless cross-account or resource-level controls require them."
  type        = map(string)
  default     = {}
}

variable "block_public_policy" {
  description = "Ask Secrets Manager to reject resource policies that would allow broad public access."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to all managed secrets."
  type        = map(string)
  default     = {}
}

variable "rds_master_user_secret_arn" {
  description = "ARN of the RDS-managed master user secret created by the RDS module. The secret is consumed, not recreated."
  type        = string
  default     = null
}

variable "redis_auth_secret_arn" {
  description = "ARN of an existing Redis authentication secret, when Redis AUTH is enabled outside this module. The secret is consumed, not recreated."
  type        = string
  default     = null
}
