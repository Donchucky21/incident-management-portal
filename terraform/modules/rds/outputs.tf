output "db_instance_identifier" {
  description = "RDS DB instance identifier"
  value       = aws_db_instance.postgres.identifier
}

output "db_address" {
  description = "RDS DB instance address"
  value       = aws_db_instance.postgres.address
}

output "db_endpoint" {
  description = "RDS DB instance endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "db_port" {
  description = "RDS DB instance port"
  value       = aws_db_instance.postgres.port
}

output "db_name" {
  description = "RDS database name"
  value       = aws_db_instance.postgres.db_name
}

output "db_subnet_group_name" {
  description = "RDS DB subnet group name"
  value       = aws_db_subnet_group.main.name
}
