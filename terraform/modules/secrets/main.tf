resource "aws_secretsmanager_secret" "database_url" {
  name        = "${var.project_name}/${var.environment}/database-url-v2"
  description = "DATABASE_URL for Incident Portal backend"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "database_url" {
  secret_id = aws_secretsmanager_secret.database_url.id

  secret_string = "postgresql://${var.db_username}:${var.db_password}@${var.db_address}:5432/${var.db_name}"
}
