variable "name_prefix" {
  description = "Prefix used for security group names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security groups will be created"
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

variable "common_tags" {
  description = "Common tags applied to security groups"
  type        = map(string)
}
