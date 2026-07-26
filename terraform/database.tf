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

resource "aws_db_instance" "main" {
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
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = false

  backup_retention_period = 1
  multi_az                = false

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${local.resource_prefix}-database"
  }
}