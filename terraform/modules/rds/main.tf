resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.private_data_subnet_ids

  tags = {
    Name = "${var.identifier}-subnet-group"
  }
}

resource "aws_db_instance" "db" {
  identifier              = var.identifier
  engine                  = var.engine
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  port                    = var.db_port
  publicly_accessible     = false
  multi_az                = var.multi_az
  storage_encrypted       = true
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
  backup_retention_period = var.backup_retention_period
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [var.db_security_group_id]
  apply_immediately       = true
  auto_minor_version_upgrade = true

  tags = {
    Name = var.identifier
  }
}