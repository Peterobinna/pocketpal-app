variable "aws_region" {
  description = "AWS region to deploy PocketPal infrastructure into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project, used for resource naming and tags"
  type        = string
  default     = "pocketpal"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the PocketPal VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet, must be within vpc_cidr"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the public subnet"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "EC2 instance type for the PocketPal server"
  type        = string
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "Name of the AWS EC2 key pair used for SSH access"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the instance, e.g. your IP followed by /32"
  type        = string
}

variable "frontend_port" {
  description = "Port used by the PocketPal frontend application"
  type        = number
  default     = 5173
}

variable "backend_port" {
  description = "Port used by the PocketPal backend application"
  type        = number
  default     = 5000
}