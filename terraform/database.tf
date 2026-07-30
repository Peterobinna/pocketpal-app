resource "aws_db_subnet_group" "main" {
  name = "${local.resource_prefix}-database-subnets"

  subnet_ids = [
    aws_subnet.database_1.id,
    aws_subnet.database_2.id
  ]

  tags = {
    Name = "${local.resource_prefix}-database-subnets"
  }
}

# Configure PostgreSQL to record connection, disconnection and
# long-running query activity for operational investigation.
resource "aws_db_parameter_group" "main" {
  name   = "${local.resource_prefix}-postgresql-parameters"
  family = "postgres16"

  # Force PostgreSQL clients to use SSL/TLS for database connections.
  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "log_statement"
    value = "ddl"
  }

  tags = {
    Name = "${local.resource_prefix}-postgresql-parameters"
  }
}

resource "aws_db_instance" "main" {
  # checkov:skip=CKV_AWS_157:Multi-AZ approximately doubles RDS compute cost and is accepted for this short-lived coursework environment. Production must enable Multi-AZ.
  # checkov:skip=CKV_AWS_353:Performance Insights is omitted for this small short-lived educational workload. Production should enable it with appropriate retention.
  # checkov:skip=CKV_AWS_118:Enhanced monitoring requires additional IAM and CloudWatch resources and is omitted for the coursework environment. PostgreSQL logs are exported instead.
  # checkov:skip=CKV_AWS_293:Deletion protection is disabled so the team can destroy billable coursework resources after grading. Production must enable deletion protection.

  identifier = "${local.resource_prefix}-database"

  engine         = "postgres"
  engine_version = "16"

  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 30
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = false

  # Export PostgreSQL and upgrade logs to CloudWatch.
  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade"
  ]

  # Apply compatible minor security and maintenance updates automatically.
  auto_minor_version_upgrade = true

  # Allow IAM database authentication in addition to the configured
  # administrator account.
  iam_database_authentication_enabled = true

  # Preserve project and environment tags when snapshots are created.
  copy_tags_to_snapshot = true

  backup_retention_period = 1
  multi_az                = false

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${local.resource_prefix}-database"
  }
}