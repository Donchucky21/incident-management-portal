output "frontend_log_group_name" {
  description = "Name of the frontend CloudWatch log group"
  value       = aws_cloudwatch_log_group.frontend.name
}

output "backend_log_group_name" {
  description = "Name of the backend CloudWatch log group"
  value       = aws_cloudwatch_log_group.backend.name
}

output "frontend_log_group_arn" {
  description = "ARN of the frontend CloudWatch log group"
  value       = aws_cloudwatch_log_group.frontend.arn
}

output "backend_log_group_arn" {
  description = "ARN of the backend CloudWatch log group"
  value       = aws_cloudwatch_log_group.backend.arn
}

output "sns_topic_arn" {
  description = "ARN of the CloudWatch alerts SNS topic"
  value       = aws_sns_topic.cloudwatch_alerts.arn
}

output "alarm_names" {
  description = "Names of the CloudWatch alarms"
  value = [
    aws_cloudwatch_metric_alarm.backend_cpu_high.alarm_name,
    aws_cloudwatch_metric_alarm.backend_memory_high.alarm_name,
    aws_cloudwatch_metric_alarm.frontend_cpu_high.alarm_name,
    aws_cloudwatch_metric_alarm.frontend_memory_high.alarm_name,
    aws_cloudwatch_metric_alarm.backend_target_5xx.alarm_name,
    aws_cloudwatch_metric_alarm.backend_unhealthy_targets.alarm_name,
    aws_cloudwatch_metric_alarm.frontend_unhealthy_targets.alarm_name,
    aws_cloudwatch_metric_alarm.rds_cpu_high.alarm_name,
    aws_cloudwatch_metric_alarm.rds_low_storage.alarm_name
  ]
}
