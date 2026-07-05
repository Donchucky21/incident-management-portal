output "database_url_secret_arn" {
  description = "ARN of the DATABASE_URL secret"
  value       = aws_secretsmanager_secret.database_url.arn
}

output "database_url_secret_id" {
  description = "ID of the DATABASE_URL secret"
  value       = aws_secretsmanager_secret.database_url.id
}

output "database_url_secret_name" {
  description = "Name of the DATABASE_URL secret"
  value       = aws_secretsmanager_secret.database_url.name
}
