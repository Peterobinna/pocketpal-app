# Common resource name and tags used throughout the configuration.
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

# Obtain the currently available availability zones for the selected region.
# This avoids hardcoding a region-specific availability-zone name.
data "aws_availability_zones" "available" {
  state = "available"
}

# Find the latest official Ubuntu 24.04 LTS image for x86-64 EC2 instances.
# Canonical's official AWS account ID is 099720109477.
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

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Create an isolated virtual network for PocketPal.
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.resource_prefix}-vpc"
  }
}

# Create a public subnet in the first available zone.
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.resource_prefix}-public-subnet"
    Tier = "public"
  }
}

# Provide internet connectivity to resources in the VPC.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.resource_prefix}-internet-gateway"
  }
}

# Create a route table for the public subnet.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.resource_prefix}-public-route-table"
  }
}

# Route internet-bound IPv4 traffic through the internet gateway.
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate the public subnet with the public route table.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security group attached to the PocketPal EC2 instance.
resource "aws_security_group" "pocketpal" {
  name_prefix = "${local.resource_prefix}-"
  description = "Network access rules for the PocketPal application server"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.resource_prefix}-security-group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Permit SSH only from the trusted public IPv4 address supplied by the user.
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.pocketpal.id
  description       = "Restricted SSH access for server configuration"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.ssh_allowed_cidr
}

# Permit public access to the PocketPal frontend.
resource "aws_vpc_security_group_ingress_rule" "frontend" {
  security_group_id = aws_security_group.pocketpal.id
  description       = "Public access to the PocketPal frontend"
  from_port         = var.frontend_port
  to_port           = var.frontend_port
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Permit access to the backend API used by the browser-based frontend.
resource "aws_vpc_security_group_ingress_rule" "backend" {
  security_group_id = aws_security_group.pocketpal.id
  description       = "Public access to the PocketPal backend API"
  from_port         = var.backend_port
  to_port           = var.backend_port
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Permit the server to download operating-system packages and container images.
resource "aws_vpc_security_group_egress_rule" "all_outbound_ipv4" {
  security_group_id = aws_security_group.pocketpal.id
  description       = "Allow required outbound IPv4 traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Provision the compute instance that Ansible will configure later.
resource "aws_instance" "pocketpal" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.pocketpal.id]

  # Detailed monitoring provides more frequent CloudWatch metrics.
  monitoring = true

  # Require Instance Metadata Service Version 2 for improved security.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Encrypt the instance's root disk.
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${local.resource_prefix}-server"
  }

  # Ensure the public route exists before the instance is provisioned.
  depends_on = [
    aws_route.public_internet,
    aws_route_table_association.public
  ]
}