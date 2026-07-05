output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "frontend_service_name" {
  description = "Frontend ECS service name"
  value       = aws_ecs_service.frontend.name
}

output "backend_service_name" {
  description = "Backend ECS service name"
  value       = aws_ecs_service.backend.name
}

output "frontend_task_definition_arn" {
  description = "Frontend ECS task definition ARN"
  value       = aws_ecs_task_definition.frontend.arn
}

output "backend_task_definition_arn" {
  description = "Backend ECS task definition ARN"
  value       = aws_ecs_task_definition.backend.arn
}

output "frontend_service_id" {
  description = "Frontend ECS service ID"
  value       = aws_ecs_service.frontend.id
}

output "backend_service_id" {
  description = "Backend ECS service ID"
  value       = aws_ecs_service.backend.id
}
