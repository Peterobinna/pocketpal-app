# Defines the Terraform and AWS provider versions required by this project.
terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# The deployment region is supplied through a Terraform variable.
# AWS credentials are obtained from the active AWS CLI profile.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}