variable "project_name" {
  description = "Project name used for log group names"
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for CloudWatch alarm and SNS names"
  type        = string
}

variable "environment" {
  description = "Environment name used for log group names"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to CloudWatch log groups"
  type        = map(string)
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer"
  type        = string
}

variable "frontend_target_group_arn_suffix" {
  description = "ARN suffix of the frontend target group"
  type        = string
}

variable "backend_target_group_arn_suffix" {
  description = "ARN suffix of the backend target group"
  type        = string
}

variable "rds_instance_identifier" {
  description = "RDS DB instance identifier"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name used in alarm dimensions"
  type        = string
}

variable "frontend_service_name" {
  description = "Frontend ECS service name used in alarm dimensions"
  type        = string
}

variable "backend_service_name" {
  description = "Backend ECS service name used in alarm dimensions"
  type        = string
}
