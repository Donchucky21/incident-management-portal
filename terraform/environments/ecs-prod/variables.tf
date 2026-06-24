variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "incident-portal"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

# variable "vpc_id" {
#   description = "Existing VPC ID"
#   type        = string
# }

# variable "public_subnet_ids" {
#   description = "Public subnet IDs for the Application Load Balancer"
#   type        = list(string)
# }

# variable "private_app_subnet_ids" {
#   description = "Private subnet IDs for ECS Fargate tasks"
#   type        = list(string)
# }

variable "frontend_image_uri" {
  description = "Full ECR image URI for the frontend container"
  type        = string
}

variable "backend_image_uri" {
  description = "Full ECR image URI for the backend container"
  type        = string
}

variable "database_url_secret_arn" {
  description = "Secrets Manager ARN containing DATABASE_URL for the backend. Leave empty only if testing without DB."
  type        = string
  default     = ""
}

variable "frontend_container_port" {
  description = "Frontend container port"
  type        = number
  default     = 8080
}

variable "backend_container_port" {
  description = "Backend container port"
  type        = number
  default     = 5000
}

variable "frontend_cpu" {
  description = "Frontend task CPU"
  type        = number
  default     = 256
}

variable "frontend_memory" {
  description = "Frontend task memory"
  type        = number
  default     = 512
}

variable "backend_cpu" {
  description = "Backend task CPU"
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Backend task memory"
  type        = number
  default     = 512
}

variable "frontend_desired_count" {
  description = "Desired number of frontend tasks"
  type        = number
  default     = 2
}

variable "backend_desired_count" {
  description = "Desired number of backend tasks"
  type        = number
  default     = 2
}

variable "min_task_count" {
  description = "Minimum ECS task count for autoscaling"
  type        = number
  default     = 1
}

variable "max_task_count" {
  description = "Maximum ECS task count for autoscaling"
  type        = number
  default     = 4
}

variable "cpu_target_value" {
  description = "CPU target percentage for ECS service autoscaling"
  type        = number
  default     = 70
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "incident_portal"
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "incident_admin"
}

variable "db_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string
}

variable "domain_name" {
  description = "Custom domain name for the incident portal"
  type        = string
}

variable "hosted_zone_name" {
  description = "Route 53 hosted zone name"
  type        = string
}