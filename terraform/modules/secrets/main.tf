resource "aws_secretsmanager_secret" "observastack_secret" {
  for_each = var.secrets

  name = "${local.name_prefix}/${each.key}"

  description = each.value.description

  kms_key_id = coalesce(
    try(each.value.kms_key_arn, null),
    var.kms_key_arn
  )

  recovery_window_in_days = coalesce(
    try(each.value.recovery_window_in_days, null),
    var.recovery_window_in_days
  )

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      SecretName = each.key
    }
  )

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_secretsmanager_secret_policy" "observastack_secret_policy" {
  for_each = var.secret_resource_policies

  secret_arn = aws_secretsmanager_secret.observastack_secret[each.key].arn
  policy     = each.value

  block_public_policy = var.block_public_policy
}
