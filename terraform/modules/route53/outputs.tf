output "zone_id" {
  description = "Route53 hosted zone ID"
  value       = data.aws_route53_zone.main.zone_id
}

output "certificate_validation_record_fqdns" {
  description = "FQDNs of ACM certificate validation records"
  value       = [for record in aws_route53_record.incident_portal_cert_validation : record.fqdn]
}

output "incident_portal_alias_fqdn" {
  description = "FQDN of the incident portal alias record"
  value       = aws_route53_record.incident_portal_alias.fqdn
}

output "https_url" {
  description = "HTTPS URL of the incident portal"
  value       = "https://${var.domain_name}"
}
