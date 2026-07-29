variable "aws_region" {
  description = "AWS region used for the PocketPal production deployment"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = length(trimspace(var.aws_region)) > 0
    error_message = "aws_region must contain a valid AWS region name."
  }
}

variable "project_name" {
  description = "Project name used in resource names and tags"
  type        = string
  default     = "pocketpal"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name may contain only lowercase letters, numbers and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment must be dev, staging or production."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block allocated to the PocketPal VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_1_cidr" {
  description = "CIDR block allocated to the first public subnet"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrnetmask(var.public_subnet_1_cidr))
    error_message = "public_subnet_1_cidr must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_2_cidr" {
  description = "CIDR block allocated to the second public subnet"
  type        = string
  default     = "10.0.2.0/24"

  validation {
    condition     = can(cidrnetmask(var.public_subnet_2_cidr))
    error_message = "public_subnet_2_cidr must be a valid IPv4 CIDR block."
  }
}

variable "application_subnet_cidr" {
  description = "CIDR block allocated to the private application subnet"
  type        = string
  default     = "10.0.10.0/24"

  validation {
    condition     = can(cidrnetmask(var.application_subnet_cidr))
    error_message = "application_subnet_cidr must be a valid IPv4 CIDR block."
  }
}

variable "database_subnet_1_cidr" {
  description = "CIDR block allocated to the first private database subnet"
  type        = string
  default     = "10.0.20.0/24"

  validation {
    condition     = can(cidrnetmask(var.database_subnet_1_cidr))
    error_message = "database_subnet_1_cidr must be a valid IPv4 CIDR block."
  }
}

variable "database_subnet_2_cidr" {
  description = "CIDR block allocated to the second private database subnet"
  type        = string
  default     = "10.0.21.0/24"

  validation {
    condition     = can(cidrnetmask(var.database_subnet_2_cidr))
    error_message = "database_subnet_2_cidr must be a valid IPv4 CIDR block."
  }
}

variable "instance_type" {
  description = "EC2 instance type used by the bastion and application server"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = length(trimspace(var.instance_type)) > 0
    error_message = "instance_type must not be empty."
  }
}

variable "ssh_key_name" {
  description = "Existing AWS EC2 key-pair name"
  type        = string

  validation {
    condition     = length(trimspace(var.ssh_key_name)) > 0
    error_message = "ssh_key_name must not be empty."
  }
}

variable "ssh_allowed_cidr" {
  description = "Trusted public IPv4 CIDR permitted to reach the bastion"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_allowed_cidr))
    error_message = "ssh_allowed_cidr must be a valid IPv4 CIDR, such as 203.0.113.10/32."
  }

  validation {
    condition     = var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "SSH must not be open to the entire internet."
  }

  validation {
    condition     = can(regex("/32$", var.ssh_allowed_cidr))
    error_message = "ssh_allowed_cidr must normally identify one trusted IPv4 address ending in /32."
  }
}

variable "frontend_port" {
  description = "Port used by the PocketPal frontend container"
  type        = number
  default     = 5173

  validation {
    condition     = var.frontend_port >= 1 && var.frontend_port <= 65535
    error_message = "frontend_port must be between 1 and 65535."
  }
}

variable "backend_port" {
  description = "Port used by the PocketPal backend container"
  type        = number
  default     = 5000

  validation {
    condition     = var.backend_port >= 1 && var.backend_port <= 65535
    error_message = "backend_port must be between 1 and 65535."
  }
}

variable "root_volume_size" {
  description = "Encrypted EC2 root volume size in GiB"
  type        = number
  default     = 10

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 30
    error_message = "root_volume_size must be between 8 and 30 GiB."
  }
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "pocketpal"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.db_name))
    error_message = "db_name must begin with a letter and contain only letters, numbers and underscores."
  }
}

variable "db_username" {
  description = "PostgreSQL administrator username"
  type        = string
  sensitive   = true

  validation {
    condition     = length(trimspace(var.db_username)) >= 3
    error_message = "db_username must contain at least three characters."
  }
}

variable "db_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 16
    error_message = "db_password must contain at least 16 characters."
  }

  validation {
    condition     = can(regex("[A-Z]", var.db_password)) && can(regex("[a-z]", var.db_password)) && can(regex("[0-9]", var.db_password))
    error_message = "db_password must contain uppercase letters, lowercase letters and numbers."
  }
}

variable "additional_tags" {
  description = "Additional tags applied to AWS resources"
  type        = map(string)
  default     = {}
}
