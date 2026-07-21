# AWS region in which the infrastructure will be created.
# This has no default so that the region must be supplied explicitly.
variable "aws_region" {
  description = "AWS region in which to deploy the PocketPal infrastructure"
  type        = string

  validation {
    condition     = length(trimspace(var.aws_region)) > 0
    error_message = "aws_region must contain a valid AWS region name."
  }
}

# Project name used when naming and tagging AWS resources.
variable "project_name" {
  description = "Project name used for AWS resource names and tags"
  type        = string
  default     = "pocketpal"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name may contain only lowercase letters, numbers and hyphens."
  }
}

# Identifies the deployment environment.
variable "environment" {
  description = "Deployment environment, such as dev, staging or production"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment must be dev, staging or production."
  }
}

# Private address range allocated to the VPC.
variable "vpc_cidr" {
  description = "IPv4 CIDR block allocated to the PocketPal VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

# Address range allocated to the public subnet.
variable "public_subnet_cidr" {
  description = "IPv4 CIDR block allocated to the public subnet"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrnetmask(var.public_subnet_cidr))
    error_message = "public_subnet_cidr must be a valid IPv4 CIDR block."
  }
}

# EC2 instance size.
variable "instance_type" {
  description = "EC2 instance type used for the PocketPal server"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = length(trimspace(var.instance_type)) > 0
    error_message = "instance_type must not be empty."
  }
}

# Existing AWS EC2 key-pair name.
variable "ssh_key_name" {
  description = "Name of the existing AWS EC2 key pair used for SSH"
  type        = string
  sensitive   = false

  validation {
    condition     = length(trimspace(var.ssh_key_name)) > 0
    error_message = "ssh_key_name must not be empty."
  }
}

# Only this IPv4 address will be permitted to connect through SSH.
variable "ssh_allowed_cidr" {
  description = "Trusted IPv4 CIDR permitted to access SSH, normally one public IP ending in /32"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_allowed_cidr))
    error_message = "ssh_allowed_cidr must be a valid IPv4 CIDR block, such as 203.0.113.10/32."
  }

  validation {
    condition     = var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "SSH must not be open to the entire internet. Supply a trusted /32 CIDR."
  }
}

# Port used by the PocketPal frontend container.
variable "frontend_port" {
  description = "Public port used by the PocketPal frontend"
  type        = number
  default     = 5173

  validation {
    condition     = var.frontend_port >= 1 && var.frontend_port <= 65535
    error_message = "frontend_port must be between 1 and 65535."
  }
}

# Port used by the PocketPal backend API container.
variable "backend_port" {
  description = "Public port used by the PocketPal backend API"
  type        = number
  default     = 5000

  validation {
    condition     = var.backend_port >= 1 && var.backend_port <= 65535
    error_message = "backend_port must be between 1 and 65535."
  }
}

# Size of the encrypted EC2 root disk.
variable "root_volume_size" {
  description = "Size of the EC2 root EBS volume in GiB"
  type        = number
  default     = 10

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 30
    error_message = "root_volume_size must be between 8 and 30 GiB."
  }
}

# Optional additional tags for AWS resources.
variable "additional_tags" {
  description = "Additional tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}