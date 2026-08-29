locals {
  name_prefix = "thesis-${var.environment}-${replace(var.region, "-", "")}"
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-eks-logs"
  })
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.name_prefix}-node-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "EKS node CPU utilization high for ${local.name_prefix}"

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-cpu-alarm"
  })
}
