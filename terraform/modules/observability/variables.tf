variable "project_name" {
  description = "Project name used in resource naming."
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

variable "kms_key_arn" {
  description = "Customer-managed KMS key ARN for CloudWatch Logs encryption."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period."
  type        = number
  default     = 30
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_retention_days)
    error_message = "Use a supported CloudWatch Logs retention period."
  }
}

variable "create_application_log_group" {
  type    = bool
  default = true
}

variable "create_platform_log_group" {
  type    = bool
  default = true
}

variable "create_audit_log_group" {
  type    = bool
  default = true
}

variable "create_alarms" {
  description = "Create baseline CloudWatch alarms."
  type        = bool
  default     = true
}

variable "alarm_actions" {
  description = "SNS topic ARNs or other CloudWatch alarm action ARNs."
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "Actions invoked when alarms return to OK."
  type        = list(string)
  default     = []
}

variable "cpu_alarm_threshold" {
  description = "EC2/EKS node CPU alarm threshold if node dimensions are supplied externally."
  type        = number
  default     = 80
}

variable "create_dashboard" {
  description = "Create an AWS CloudWatch dashboard for infrastructure signals."
  type        = bool
  default     = true
}

variable "dashboard_body" {
  description = "Optional CloudWatch dashboard JSON body. When null, a baseline dashboard is generated."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional resource tags."
  type        = map(string)
  default     = {}
}
