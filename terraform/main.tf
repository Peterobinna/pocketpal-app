# Shared names and tags used throughout the infrastructure.
locals {
  resource_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Application = "PocketPal"
    },
    var.additional_tags
  )
}

# Obtain available zones without hardcoding region-specific AZ names.
data "aws_availability_zones" "available" {
  state = "available"
}

# Find the latest official Ubuntu 24.04 LTS image.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}