variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition = contains(
      ["dev", "staging", "production"],
      var.environment
    )

    error_message = "Environment must be dev, staging, or production."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string

  validation {
    condition     = can(regex("^1\\.[0-9]+$", var.kubernetes_version))
    error_message = "kubernetes_version must use the format 1.xx."
  }
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the EKS control plane and worker nodes."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "EKS requires at least two private subnets."
  }
}

variable "cluster_role_arn" {
  description = "IAM role ARN for the EKS control plane."
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for EKS managed node groups."
  type        = string
}

variable "cluster_endpoint_private_access" {
  description = "Enable private EKS API endpoint access."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public EKS API endpoint access."
  type        = bool
  default     = false
}

variable "cluster_enabled_log_types" {
  description = "EKS control-plane log types."
  type        = list(string)

  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}

variable "cluster_log_retention_days" {
  description = "CloudWatch retention period for EKS control-plane logs."
  type        = number
  # default     = 30
  default = 0 # for testing purposes only
}

variable "cluster_log_kms_key_arn" {
  description = "KMS key ARN used to encrypt EKS control-plane logs."
  type        = string
}

variable "cluster_encryption_kms_key_arn" {
  description = "KMS key ARN used for Kubernetes secrets encryption."
  type        = string
}

variable "node_group_instance_types" {
  description = "EC2 instance types for the default managed node group."
  type        = list(string)

  default = [
    "t3.medium"
  ]
}

variable "node_group_capacity_type" {
  description = "Capacity type for the managed node group."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition = contains(
      ["ON_DEMAND", "SPOT"],
      var.node_group_capacity_type
    )

    error_message = "Capacity type must be ON_DEMAND or SPOT."
  }
}

variable "node_group_min_size" {
  description = "Minimum node count."
  type        = number
  default     = 2
}

variable "node_group_desired_size" {
  description = "Desired node count."
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum node count."
  type        = number
  default     = 4
}

variable "node_group_disk_size" {
  description = "EBS volume size in GiB for worker nodes."
  type        = number
  default     = 50
}

variable "node_group_labels" {
  description = "Kubernetes labels applied to the managed node group."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional resource tags."
  type        = map(string)
  default     = {}
}

variable "access_entries" {
  description = "IAM principals allowed to access the EKS cluster."
  type = map(object({
    principal_arn = string
    policy_arns   = list(string)
  }))

  default = {}
}

variable "ebs_csi_role_arn" {
  description = "Dedicated Pod Identity role for Amazon EBS CSI."
  type        = string
}

variable "vpc_cni_role_arn" {
  description = "Dedicated Pod Identity role for Amazon VPC CNI."
  type        = string
}