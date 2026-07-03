variable "project_name" {
  description = "Project name displayed by the Nginx landing page"
  type        = string
}

variable "environment" {
  description = "Environment name displayed by the Nginx landing page"
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for EC2 hosting resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EC2 host will be created"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID where the EC2 host will be created"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the Nginx host"
  type        = string
}

variable "key_name" {
  description = "Optional EC2 key pair name for SSH access"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags applied to EC2 hosting resources"
  type        = map(string)
}
