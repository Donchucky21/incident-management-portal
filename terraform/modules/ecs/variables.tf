variable "name_prefix" {
  description = "Prefix used for ECS resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS region used for awslogs configuration"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to ECS resources"
  type        = map(string)
}

variable "frontend_image_uri" {
  description = "Full ECR image URI for the frontend container"
  type        = string
}

variable "backend_image_uri" {
  description = "Full ECR image URI for the backend container"
  type        = string
}

variable "frontend_container_port" {
  description = "Frontend container port"
  type        = number
}

variable "backend_container_port" {
  description = "Backend container port"
  type        = number
}

variable "frontend_cpu" {
  description = "Frontend task CPU"
  type        = number
}

variable "frontend_memory" {
  description = "Frontend task memory"
  type        = number
}

variable "backend_cpu" {
  description = "Backend task CPU"
  type        = number
}

variable "backend_memory" {
  description = "Backend task memory"
  type        = number
}

variable "frontend_desired_count" {
  description = "Desired number of frontend tasks"
  type        = number
}

variable "backend_desired_count" {
  description = "Desired number of backend tasks"
  type        = number
}

variable "min_task_count" {
  description = "Minimum ECS task count for autoscaling"
  type        = number
}

variable "max_task_count" {
  description = "Maximum ECS task count for autoscaling"
  type        = number
}

variable "cpu_target_value" {
  description = "CPU target percentage for ECS service autoscaling"
  type        = number
}

variable "private_app_subnet_ids" {
  description = "Private app subnet IDs for ECS Fargate tasks"
  type        = list(string)
}

variable "ecs_tasks_security_group_id" {
  description = "Security group ID for ECS Fargate tasks"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "frontend_log_group_name" {
  description = "Frontend CloudWatch log group name"
  type        = string
}

variable "backend_log_group_name" {
  description = "Backend CloudWatch log group name"
  type        = string
}

variable "database_url_secret_arn" {
  description = "Secrets Manager ARN containing DATABASE_URL for the backend"
  type        = string
}

variable "frontend_target_group_arn" {
  description = "Frontend ALB target group ARN"
  type        = string
}

variable "backend_target_group_arn" {
  description = "Backend ALB target group ARN"
  type        = string
}
