variable "project_name" { type = string }

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "vpc_id" { type = string }

variable "database_subnet_ids" {
  type = list(string)
  validation {
    condition     = length(var.database_subnet_ids) >= 2
    error_message = "RDS requires at least two database subnets."
  }
}

variable "kms_key_arn" {
  description = "Environment-specific customer-managed KMS key for RDS."
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL version; verify regional availability before apply."
  type        = string
  default     = "17.6"
}

variable "instance_class" { 
  type = string 
  default = "db.t4g.micro" 
}

variable "allocated_storage" {
   type = number 
   default = 20 
}

variable "max_allocated_storage" { 
  type = number 
  # default = 100 
  default = 30 # for testing purposes, can be increased for production
}

variable "storage_type" {
  type    = string
  default = "gp3"
  validation {
    condition     = contains(["gp3", "io1", "io2"], var.storage_type)
    error_message = "storage_type must be gp3, io1, or io2."
  }
}

variable "multi_az" { 
  type = bool 
  default = true 
}

variable "backup_retention_period" {
  type    = number
  #default = 7
  default = 0 # for testing purposes, can be increased for production
  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 0
    error_message = "backup_retention_period must be between 1 and 35." # for testing purposes, can be increased for production
  }
  # validation {
  #   condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
  #   error_message = "backup_retention_period must be between 1 and 35."
  # }
}

variable "backup_window" { 
  type = string 
  default = "03:00-03:30" 
}

variable "maintenance_window" { 
  type = string 
  default = "sun:04:00-sun:04:30" 
}

variable "deletion_protection" { 
  type = bool 
  default = true 
}

variable "skip_final_snapshot" { 
  type = bool 
  default = false 
}

variable "final_snapshot_identifier" { 
  type = string 
  default = null 
}

variable "apply_immediately" { 
  type = bool 
  default = false 
}

variable "publicly_accessible" {
  type    = bool
  default = false
  validation {
    condition     = var.publicly_accessible == false
    error_message = "ObservaStack RDS must remain private."
  }
}

variable "allowed_security_group_ids" {
  description = "Client security groups allowed to connect to PostgreSQL."
  type        = list(string)
  default     = []
}

variable "database_port" { 
  type = number 
  default = 5432 
}

variable "database_name" { 
  type = string 
  default = "observastack" 
}
variable "master_username" { 
  type = string 
  default = "observastack_admin" 
}

variable "manage_master_user_password" { 
  type = bool 
  default = true 
}

variable "enabled_cloudwatch_logs_exports" {
  type    = list(string)
  default = ["postgresql", "upgrade"]
}

variable "parameter_family" { 
  type = string 
  default = "postgres17" 
}

variable "force_ssl" { 
  type = bool 
  default = true 
}

variable "enable_performance_insights" { 
  type = bool 
  default = true 
}

variable "performance_insights_retention_period" { 
  type = number 
  default = 7 
}

variable "monitoring_interval" {
  type    = number
  default = 0
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "monitoring_interval must be 0, 1, 5, 10, 15, 30, or 60."
  }
}

variable "monitoring_role_arn" { 
  type = string 
  default = null 
}

variable "tags" { 
  type = map(string) 
  default = {} 
}
