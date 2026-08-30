output "log_group_name" {
  description = "Log group owned by this module (not the EKS control-plane group)."
  value       = aws_cloudwatch_log_group.application.name
}

output "cpu_alarm_names" {
  description = "Map of service name → RDS CPU alarm name."
  value       = { for name, alarm in aws_cloudwatch_metric_alarm.cpu_high : name => alarm.alarm_name }
}
