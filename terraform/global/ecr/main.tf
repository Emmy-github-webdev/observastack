module "ecr" {
  source = "../../modules/ecr"

  project_name = "observastack"

  repository_name = "observastack"

  kms_key_arn = var.kms_key_arn

  scan_on_push      = true
  image_tag_mutability = "IMMUTABLE"

  force_delete = false

  untagged_image_expiration_days = 7

  tags = {
    CostCenter = "observastack-platform"
  }
}