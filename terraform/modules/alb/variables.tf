variable "name_prefix" {
  description = "Prefix used for ALB resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB target groups will be created"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID to associate with the ALB"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "frontend_container_port" {
  description = "Frontend container port"
  type        = number
}

variable "backend_container_port" {
  description = "Backend container port"
  type        = number
}

variable "common_tags" {
  description = "Common tags applied to ALB resources"
  type        = map(string)
}
