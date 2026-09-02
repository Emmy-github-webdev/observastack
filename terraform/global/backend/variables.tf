variable "aws_region" {
  type        = string
  description = "AWS region where the Terraform state bucket is created."
}

variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform state."
}

variable "force_destroy" {
  type        = bool
  description = "Whether Terraform may delete the bucket when it contains objects."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Additional tags."
  default     = {}
}
