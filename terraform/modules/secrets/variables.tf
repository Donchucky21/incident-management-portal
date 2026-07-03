variable "project_name" {
  description = "Project name used for secret naming"
  type        = string
}

variable "environment" {
  description = "Environment name used for secret naming"
  type        = string
}

variable "db_username" {
  description = "PostgreSQL username for the DATABASE_URL"
  type        = string
}

variable "db_password" {
  description = "PostgreSQL password for the DATABASE_URL"
  type        = string
  sensitive   = true
}

variable "db_address" {
  description = "RDS database address for the DATABASE_URL"
  type        = string
}

variable "db_name" {
  description = "PostgreSQL database name for the DATABASE_URL"
  type        = string
}
