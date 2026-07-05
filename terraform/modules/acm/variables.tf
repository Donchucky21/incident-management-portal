variable "project_name" {
  description = "Project name used for ACM certificate tags"
  type        = string
}

variable "environment" {
  description = "Environment name used for ACM certificate tags"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the ACM certificate"
  type        = string
}

variable "validation_record_fqdns" {
  description = "FQDNs of Route53 records used for ACM certificate validation"
  type        = list(string)
}
