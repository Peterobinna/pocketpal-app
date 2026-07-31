resource "aws_vpc" "main" {
  # checkov:skip=CKV2_AWS_11:VPC Flow Logs incur ongoing CloudWatch ingestion and storage costs and are omitted from this short-lived coursework environment. Production must enable centralized flow logging.

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.resource_prefix}-vpc"
  }
}

# Explicitly restrict the default VPC security group.
# Every application resource uses its own purpose-specific security group.
resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id

  ingress = []
  egress  = []

  tags = {
    Name = "${local.resource_prefix}-default-deny-sg"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.resource_prefix}-igw"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_1_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  # Public IP assignment is controlled per EC2 instance.
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.resource_prefix}-public-1"
    Tier = "public"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_2_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  # The ALB does not require subnet-level automatic EC2 public IP assignment.
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.resource_prefix}-public-2"
    Tier = "public"
  }
}

resource "aws_subnet" "application" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.application_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.resource_prefix}-application-private"
    Tier = "private"
  }
}

resource "aws_subnet" "database_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.database_subnet_1_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.resource_prefix}-database-1"
    Tier = "private"
  }
}

resource "aws_subnet" "database_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.database_subnet_2_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.resource_prefix}-database-2"
    Tier = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.resource_prefix}-public-routes"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# The NAT Gateway allows the private application instance to download
# packages and pull ECR images without receiving a public IP address.
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${local.resource_prefix}-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${local.resource_prefix}-nat"
  }
}

resource "aws_route_table" "application_private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${local.resource_prefix}-application-private-routes"
  }
}

resource "aws_route_table_association" "application" {
  subnet_id      = aws_subnet.application.id
  route_table_id = aws_route_table.application_private.id
}