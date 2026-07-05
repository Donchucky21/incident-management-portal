variable "name_prefix" {
  description = "Prefix used for IAM resource names"
  type        = string
}

variable "database_url_secret_arn" {
  description = "ARN of the DATABASE_URL secret ECS tasks can read"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to IAM resources"
  type        = map(string)
}
