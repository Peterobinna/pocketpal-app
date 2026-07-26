variable "aws_region" {
  description = "AWS region used for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in resource names"
  type        = string
  default     = "pocketpal"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging or production."
  }
}

variable "vpc_cidr" {
  description = "CIDR allocated to the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "application_subnet_cidr" {
  type    = string
  default = "10.0.10.0/24"
}

variable "database_subnet_1_cidr" {
  type    = string
  default = "10.0.20.0/24"
}

variable "database_subnet_2_cidr" {
  type    = string
  default = "10.0.21.0/24"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ssh_key_name" {
  description = "Existing AWS EC2 key-pair name"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Trusted public IPv4 address ending in /32"
  type        = string

  validation {
    condition     = var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "SSH must not be open to the entire internet."
  }
}

variable "frontend_port" {
  type    = number
  default = 5173
}

variable "backend_port" {
  type    = number
  default = 5000
}

variable "root_volume_size" {
  type    = number
  default = 10
}

variable "db_name" {
  type    = string
  default = "pocketpal"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true

  validation {
    condition     = length(var.db_password) >= 12
    error_message = "Database password must contain at least 12 characters."
  }
}

variable "additional_tags" {
  type    = map(string)
  default = {}
}