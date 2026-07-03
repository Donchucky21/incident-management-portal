variable "project_name" {
  description = "Project name used for log group names"
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
