variable "vpc_id" {
  description = "VPC ID where the security groups will be created"
  type        = string
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "my_ip" {
  description = "Your public IP address for SSH access to bastion"
  type        = string
}