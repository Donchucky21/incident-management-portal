resource "aws_acm_certificate" "incident_portal" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-certificate"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_acm_certificate_validation" "incident_portal" {
  certificate_arn         = aws_acm_certificate.incident_portal.arn
  validation_record_fqdns = var.validation_record_fqdns
}
