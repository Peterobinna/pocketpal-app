resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-frontend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  # Use the AWS-managed ECR KMS key.
  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = {
    Name = "${local.resource_prefix}-frontend-ecr"
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-backend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  # Use the AWS-managed ECR KMS key.
  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = {
    Name = "${local.resource_prefix}-backend-ecr"
  }
}