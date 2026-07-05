output "ec2_public_ip" {
  description = "Public IP address of the EC2 Nginx host"
  value       = module.ec2_hosting.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 Nginx host"
  value       = module.ec2_hosting.public_dns
}

output "website_url" {
  description = "HTTP URL for the EC2 Nginx host"
  value       = module.ec2_hosting.website_url
}
