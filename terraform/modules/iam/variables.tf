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

variable "create_eks_cluster_role" {
  description = "Create the IAM role used by the EKS control plane."
  type        = bool
  default     = true
}

variable "create_eks_node_role" {
  description = "Create the IAM role used by EKS worker nodes."
  type        = bool
  default     = true
}

variable "create_load_balancer_role" {
  description = "Create the IAM role used by the AWS Load Balancer Controller."
  type        = bool
  default     = true
}

variable "create_external_secrets_role" {
  description = "Create the IAM role used by External Secrets."
  type        = bool
  default     = true
}

variable "create_application_roles" {
  description = "Create IAM roles for ObservaStack application workloads."
  type        = bool
  default     = true
}

variable "application_names" {
  description = "Application workloads that require dedicated IAM roles."
  type        = set(string)

  default = [
    "user-service",
    "product-service",
    "order-service",
    "payment-service"
  ]

  validation {
    condition = alltrue([
      for name in var.application_names :
      can(regex("^[a-z0-9-]+$", name))
    ])

    error_message = "Application names may only contain lowercase letters, numbers, and hyphens."
  }
}

variable "tags" {
  description = "Additional resource tags."
  type        = map(string)
  default     = {}
}

variable "create_vpc_cni_role" {
  description = "Create a dedicated EKS Pod Identity role for the Amazon VPC CNI add-on."
  type        = bool
  default     = true
}

variable "create_ebs_csi_role" {
  description = "Create a dedicated EKS Pod Identity role for the Amazon EBS CSI Driver add-on."
  type        = bool
  default     = true
}