module "naming" {
  source = "../naming"

  environment = var.environment
  region      = var.region
}

locals {
  name_prefix = module.naming.prefix
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

  dimensions = {
    DBInstanceIdentifier = each.value
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-${each.key}-cpu-alarm"
  })
}
