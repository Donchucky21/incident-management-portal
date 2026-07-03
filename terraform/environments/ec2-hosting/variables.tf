variable "aws_region" {
  description = "AWS region for the EC2 hosting stack"
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
  default     = "ec2-hosting"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the Nginx host"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Optional EC2 key pair name for SSH access"
  type        = string
  default     = null
}
