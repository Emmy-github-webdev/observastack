####################################
## ECR Repository
####################################

resource "aws_ecr_repository" "observastack_ecr" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = local.common_tags
}

####################################
## Lifecycle policy
####################################

resource "aws_ecr_lifecycle_policy" "observastack_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.observastack_ecr.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1

        description = "Expire untagged images after 7 days"

        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_expiration_days
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}

