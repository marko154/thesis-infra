output "log_group_name" {
  description = "Log group owned by this module (not the EKS control-plane group)."
  value       = aws_cloudwatch_log_group.application.name
}

output "cpu_alarm_names" {
  description = "Map of service name → RDS CPU alarm name."
  value       = { for name, alarm in aws_cloudwatch_metric_alarm.cpu_high : name => alarm.alarm_name }
}

output "alarm_topic_arn" {
  description = "SNS topic every alarm in this module notifies."
  value       = aws_sns_topic.alarms.arn
}

output "alarm_names" {
  description = "Every alarm name owned by this module, across all three metrics."
  value = concat(
    [for alarm in aws_cloudwatch_metric_alarm.cpu_high : alarm.alarm_name],
    [for alarm in aws_cloudwatch_metric_alarm.storage_low : alarm.alarm_name],
    [for alarm in aws_cloudwatch_metric_alarm.connections_high : alarm.alarm_name],
  )
}
