variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "repository_name" {
  description = "Name of the ECR repository."
  type        = string
  default     = "observastack"

  validation {
    condition     = can(regex("^[a-z0-9]+(?:[._/-][a-z0-9]+)*$", var.repository_name))
    error_message = "Repository name must contain only lowercase letters, numbers, and valid ECR separators."
  }
}

variable "kms_key_arn" {
  description = "ARN of the customer-managed KMS key used to encrypt the ECR repository."
  type        = string
}

variable "scan_on_push" {
  description = "Enable ECR image scanning when images are pushed."
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  description = "ECR image tag mutability setting."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition = contains(
      ["IMMUTABLE", "MUTABLE"],
      var.image_tag_mutability
    )

    error_message = "image_tag_mutability must be IMMUTABLE or MUTABLE."
  }
}

variable "force_delete" {
  description = "Whether Terraform may delete the repository when it contains images."
  type        = bool
  default     = false
}

variable "untagged_image_expiration_days" {
  description = "Number of days before untagged images are expired."
  type        = number
  default     = 7

  validation {
    condition     = var.untagged_image_expiration_days >= 1
    error_message = "Untagged image expiration must be at least 1 day."
  }
}

variable "tagged_image_retention_count" {
  description = "Maximum number of tagged images retained by the lifecycle policy."
  type        = number
  default     = 7

  validation {
    condition     = var.tagged_image_retention_count >= 1
    error_message = "Tagged image retention count must be at least 1."
  }
}

variable "tags" {
  description = "Additional resource tags."
  type        = map(string)
  default     = {}
}