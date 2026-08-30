module "naming" {
  source = "../naming"

  environment = var.environment
  region      = var.region
}

locals {
  name_prefix = module.naming.prefix

  # PostgreSQL derives max_connections from instance memory; alarm before the
  # ceiling rather than at it.
  max_connections_map = {
    small  = 112
    medium = 225
    large  = 450
  }

  connection_threshold = floor(lookup(local.max_connections_map, var.db_instance_size, local.max_connections_map.small) * 0.8)
  free_storage_bytes   = floor(var.db_storage_gb * pow(1024, 3) * var.free_storage_threshold_percent / 100)
}

# Without a notification target the alarms below change state and tell nobody.
resource "aws_sns_topic" "alarms" {
  name = "${local.name_prefix}-alarms"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-alarms"
  })
}

resource "aws_sns_topic_subscription" "alarms_email" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# Own name: EKS creates /aws/eks/<cluster>/cluster when control-plane logging is on.
resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/thesis/${var.cluster_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-logs"
  })
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  for_each = var.db_identifiers

  alarm_name          = "${local.name_prefix}-${each.key}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "RDS CPU utilization high for ${each.value}"

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = each.value
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-${each.key}-cpu-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "storage_low" {
  for_each = var.db_identifiers

  alarm_name          = "${local.name_prefix}-${each.key}-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = local.free_storage_bytes
  alarm_description   = "RDS free storage below ${var.free_storage_threshold_percent}% for ${each.value}"

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = each.value
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-${each.key}-storage-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "connections_high" {
  for_each = var.db_identifiers

  alarm_name          = "${local.name_prefix}-${each.key}-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = local.connection_threshold
  alarm_description   = "RDS connection count approaching the ceiling for ${each.value}"

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = each.value
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-${each.key}-connections-alarm"
  })
}
