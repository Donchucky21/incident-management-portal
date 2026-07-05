variable "hosted_zone_name" {
  description = "Route53 hosted zone name"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the incident portal"
  type        = string
}

variable "certificate_domain_validation_options" {
  description = "ACM certificate DNS validation options"
  type        = any
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  type        = string
}

variable "alb_zone_id" {
  description = "Hosted zone ID of the Application Load Balancer"
  type        = string
}
