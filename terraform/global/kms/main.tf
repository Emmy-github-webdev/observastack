data "aws_iam_policy_document" "key_policy" {
  statement {
    sid    = "EnableRootAccountPermissions"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "kms:*"
    ]

    resources = ["*"]
  }
}

resource "aws_kms_key" "ecr" {
  description             = var.description
  enable_key_rotation    = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days
  policy                  = data.aws_iam_policy_document.key_policy.json

  tags = local.common_tags
}

resource "aws_kms_alias" "ecr" {
  name          = local.key_alias
  target_key_id = aws_kms_key.ecr.key_id
}