variable "kubernetes_version" {
  description = "EKS Kubernetes version for the development environment."
  type        = string
  default     = "1.35"
}

variable "node_group_instance_types" {
  description = "EC2 instance types for the EKS development managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS Kubernetes API endpoint is publicly reachable."
  type        = bool
  default     = true
}

variable "rds_engine_version" {
  description = "PostgreSQL engine version. Verify availability in us-east-1 before apply."
  type        = string
  default     = "17.6"
}
