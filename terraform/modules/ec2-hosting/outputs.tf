output "instance_id" {
  description = "ID of the EC2 Nginx host"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP address of the EC2 Nginx host"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 Nginx host"
  value       = aws_instance.web.public_dns
}

output "security_group_id" {
  description = "Security group ID for the EC2 Nginx host"
  value       = aws_security_group.web.id
}

output "website_url" {
  description = "HTTP URL for the EC2 Nginx host"
  value       = "http://${aws_instance.web.public_dns}"
}
