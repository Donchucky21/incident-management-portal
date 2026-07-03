output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID for Route 53 alias records"
  value       = module.alb.alb_zone_id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.ecs_cluster_name
}

output "frontend_service_name" {
  description = "Frontend ECS service name"
  value       = module.ecs.frontend_service_name
}

output "backend_service_name" {
  description = "Backend ECS service name"
  value       = module.ecs.backend_service_name
}

output "frontend_target_group_arn" {
  description = "Frontend target group ARN"
  value       = module.alb.frontend_target_group_arn
}

output "backend_target_group_arn" {
  description = "Backend target group ARN"
  value       = module.alb.backend_target_group_arn
}

output "frontend_log_group" {
  description = "Frontend CloudWatch log group"
  value       = module.cloudwatch.frontend_log_group_name
}

output "backend_log_group" {
  description = "Backend CloudWatch log group"
  value       = module.cloudwatch.backend_log_group_name
}

output "https_url" {
  description = "HTTPS URL of the incident portal"
  value       = module.route53.https_url
}
