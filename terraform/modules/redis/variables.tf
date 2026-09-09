variable "project_name" { type = string }

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "vpc_id" { type = string }

variable "cache_subnet_ids" {
  description = "Private cache subnet IDs."
  type        = list(string)
  validation {
    condition     = length(var.cache_subnet_ids) >= 2
    error_message = "Redis requires at least two cache subnets."
  }
}

variable "kms_key_arn" {
  description = "Environment-specific customer-managed KMS key ARN."
  type        = string
}

variable "node_type" {
  description = "ElastiCache node type."
  type        = string
  default     = "cache.t4g.micro"
}

variable "engine_version" {
  description = "Redis OSS engine version. Verify regional support before apply."
  type        = string
  default     = "7.2"
}

variable "port" {
  type    = number
  default = 6379
}

variable "num_cache_clusters" {
  description = "Number of cache nodes. For Multi-AZ automatic failover this should be at least two."
  type        = number
  default     = 2

  validation {
    condition     = var.num_cache_clusters >= 1
    error_message = "num_cache_clusters must be at least 1."
  }
}

variable "automatic_failover_enabled" {
  type    = bool
  default = true
}

variable "multi_az_enabled" {
  type    = bool
  default = true
}

variable "snapshot_retention_limit" {
  type    = number
  default = 7

  validation {
    condition     = var.snapshot_retention_limit >= 0 && var.snapshot_retention_limit <= 35
    error_message = "snapshot_retention_limit must be between 0 and 35 days."
  }
}

variable "snapshot_window" {
  type    = string
  default = "02:00-03:00"
}

variable "maintenance_window" {
  type    = string
  default = "sun:03:00-sun:04:00"
}

variable "apply_immediately" {
  type    = bool
  default = false
}

variable "at_rest_encryption_enabled" {
  type    = bool
  default = true
}

variable "transit_encryption_enabled" {
  type    = bool
  default = true
}

variable "auth_token" {
  description = "Optional Redis AUTH token. Sensitive; supply through a secure CI/variable mechanism."
  type        = string
  sensitive   = true
  default     = null
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect to Redis."
  type        = list(string)
  default     = []
}

variable "parameter_group_family" {
  description = "ElastiCache parameter group family matching the Redis major version."
  type        = string
  default     = "redis7"
}

variable "log_delivery_enabled" {
  description = "Enable Redis engine and slow-log delivery to CloudWatch Logs."
  type        = bool
  default     = true
}

variable "log_group_name" {
  description = "CloudWatch log group name for Redis logs."
  type        = string
  default     = null
}

variable "log_delivery_log_format" {
  description = "Redis log format."
  type        = string
  default     = "json"
}

variable "tags" {
  type    = map(string)
  default = {}
}
