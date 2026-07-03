output "domain_name" {
  description = "The domain name for the ACM certificate."
  value       = var.domain_name
}

output "certificate_arn" {
  description = "ARN of the validated ACM certificate."
  value       = aws_acm_certificate_validation.incident_portal.certificate_arn
}

output "unvalidated_certificate_arn" {
  description = "ARN of the ACM certificate before validation."
  value       = aws_acm_certificate.incident_portal.arn
}

output "domain_validation_options" {
  description = "DNS validation options for the ACM certificate."
  value       = aws_acm_certificate.incident_portal.domain_validation_options
}
