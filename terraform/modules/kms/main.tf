resource "aws_kms_key" "observaStack_kms_key" {
  description = var.description

  key_usage = "ENCRYPT_DECRYPT"

  enable_key_rotation = var.enable_key_rotation

  deletion_window_in_days = var.deletion_window_in_days

  policy = jsonencode({
    Version = "2012-10-17"

    Id = "${local.name_prefix}-kms-policy"

    Statement = [
      {
        Sid    = "EnableAccountRootPermissions"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_kms_alias" "observaStack_kms_alias" {
  name          = local.key_alias
  target_key_id = aws_kms_key.observaStack_kms_key.key_id
}