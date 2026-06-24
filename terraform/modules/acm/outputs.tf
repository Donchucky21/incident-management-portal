output "domain_name" {
  description = "The domain name for the ACM certificate."
  value       = var.domain_name
}

output "certificate_arn" {
  description = "The ARN of the ACM certificate."
  value       = aws_acm_certificate.acm_certificate.arn
}

output "domain_validation_options" {
  value = aws_acm_certificate.acm_certificate.domain_validation_options
}