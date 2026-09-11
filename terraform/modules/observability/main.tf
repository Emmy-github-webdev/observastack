resource "aws_cloudwatch_log_group" "application" {
  count             = var.create_application_log_group ? 1 : 0
  name              = local.log_groups.application
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "platform" {
  count             = var.create_platform_log_group ? 1 : 0
  name              = local.log_groups.platform
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "audit" {
  count             = var.create_audit_log_group ? 1 : 0
  name              = local.log_groups.audit
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
  tags              = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "log_delivery_errors" {
  count = var.create_alarms ? 1 : 0

  alarm_name          = "${local.name_prefix}-log-delivery-errors"
  alarm_description   = "Baseline alarm for CloudWatch Logs delivery errors."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DeliveryErrors"
  namespace           = "AWS/Logs"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions

  tags = local.common_tags
}

resource "aws_cloudwatch_dashboard" "observastack_cloudwatch_dashboard" {
  count = var.create_dashboard ? 1 : 0

  dashboard_name = "${local.name_prefix}-observability"

  dashboard_body = coalesce(
    var.dashboard_body,
    jsonencode({
      widgets = [
        {
          type   = "text"
          x      = 0
          y      = 0
          width  = 24
          height = 2

          properties = {
            markdown = "# ObservaStack ${var.environment} — AWS Observability\n\nBaseline CloudWatch signals. Kubernetes-native Prometheus, Grafana, Loki, Tempo and OpenTelemetry remain GitOps-managed."
          }
        },
        {
          type   = "metric"
          x      = 0
          y      = 2
          width  = 12
          height = 6

          properties = {
            title  = "CloudWatch Logs Incoming Bytes"
            region = data.aws_region.current.region

            metrics = [
              [
                "AWS/Logs",
                "IncomingBytes",
                "LogGroupName",
                aws_cloudwatch_log_group.application[0].name,
                {
                  label = "Application"
                  stat  = "Sum"
                }
              ],
              [
                "AWS/Logs",
                "IncomingBytes",
                "LogGroupName",
                aws_cloudwatch_log_group.platform[0].name,
                {
                  label = "Platform"
                  stat  = "Sum"
                }
              ],
              [
                "AWS/Logs",
                "IncomingBytes",
                "LogGroupName",
                aws_cloudwatch_log_group.audit[0].name,
                {
                  label = "Audit"
                  stat  = "Sum"
                }
              ]
            ]

            period = 300
            stat   = "Sum"
            view   = "timeSeries"
          }
        }
      ]
    })
  )
}