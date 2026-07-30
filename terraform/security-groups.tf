# ---------------------------------------------------------------------------
# SECURITY-GROUP CONTAINERS
#
# Security groups are created without inline rules. Rules are declared as
# separate resources below, preventing dependency cycles between the load
# balancer, bastion, application and database security groups.
# ---------------------------------------------------------------------------

resource "aws_security_group" "load_balancer" {
  name        = "${local.resource_prefix}-alb-sg"
  description = "Security group for the public application load balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.resource_prefix}-alb-sg"
  }
}

resource "aws_security_group" "bastion" {
  name        = "${local.resource_prefix}-bastion-sg"
  description = "Security group for restricted bastion SSH access"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.resource_prefix}-bastion-sg"
  }
}

resource "aws_security_group" "application" {
  name        = "${local.resource_prefix}-application-sg"
  description = "Security group for the private application server"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.resource_prefix}-application-sg"
  }
}

resource "aws_security_group" "database" {
  name        = "${local.resource_prefix}-database-sg"
  description = "Security group for the private PostgreSQL database"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.resource_prefix}-database-sg"
  }
}

# ---------------------------------------------------------------------------
# LOAD BALANCER RULES
# ---------------------------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "load_balancer_http" {
  # checkov:skip=CKV_AWS_260:Public HTTP is required because the coursework environment does not have a domain or ACM certificate. Production must use HTTPS.

  security_group_id = aws_security_group.load_balancer.id

  description = "Allow public HTTP traffic"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "load_balancer_frontend" {
  security_group_id = aws_security_group.load_balancer.id

  description                  = "Forward frontend traffic to application server"
  referenced_security_group_id = aws_security_group.application.id
  from_port                    = var.frontend_port
  to_port                      = var.frontend_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "load_balancer_backend" {
  security_group_id = aws_security_group.load_balancer.id

  description                  = "Forward backend traffic to application server"
  referenced_security_group_id = aws_security_group.application.id
  from_port                    = var.backend_port
  to_port                      = var.backend_port
  ip_protocol                  = "tcp"
}

# ---------------------------------------------------------------------------
# BASTION RULES
# ---------------------------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id

  description = "Allow SSH from one trusted administrator address"
  cidr_ipv4   = var.ssh_allowed_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "bastion_ssh_to_application" {
  security_group_id = aws_security_group.bastion.id

  description                  = "Allow SSH forwarding to private application server"
  referenced_security_group_id = aws_security_group.application.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "bastion_https" {
  security_group_id = aws_security_group.bastion.id

  description = "Allow HTTPS for package and security updates"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "bastion_http" {
  security_group_id = aws_security_group.bastion.id

  description = "Allow HTTP for operating-system package repositories"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "bastion_dns_udp" {
  security_group_id = aws_security_group.bastion.id

  description = "Allow DNS resolution over UDP inside the VPC"
  cidr_ipv4   = var.vpc_cidr
  from_port   = 53
  to_port     = 53
  ip_protocol = "udp"
}

resource "aws_vpc_security_group_egress_rule" "bastion_dns_tcp" {
  security_group_id = aws_security_group.bastion.id

  description = "Allow DNS resolution over TCP inside the VPC"
  cidr_ipv4   = var.vpc_cidr
  from_port   = 53
  to_port     = 53
  ip_protocol = "tcp"
}

# ---------------------------------------------------------------------------
# APPLICATION SERVER RULES
# ---------------------------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "application_ssh" {
  # checkov:skip=CKV_AWS_24:SSH is not open to 0.0.0.0/0. Access is restricted to instances associated with the bastion security group.

  security_group_id = aws_security_group.application.id

  description                  = "Allow SSH from bastion security group only"
  referenced_security_group_id = aws_security_group.bastion.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "application_frontend" {
  security_group_id = aws_security_group.application.id

  description                  = "Allow frontend traffic from load balancer"
  referenced_security_group_id = aws_security_group.load_balancer.id
  from_port                    = var.frontend_port
  to_port                      = var.frontend_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "application_backend" {
  security_group_id = aws_security_group.application.id

  description                  = "Allow backend traffic from load balancer"
  referenced_security_group_id = aws_security_group.load_balancer.id
  from_port                    = var.backend_port
  to_port                      = var.backend_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "application_https" {
  security_group_id = aws_security_group.application.id

  description = "Allow HTTPS for ECR, AWS APIs and package downloads"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "application_http" {
  security_group_id = aws_security_group.application.id

  description = "Allow HTTP for operating-system package repositories"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "application_postgresql" {
  security_group_id = aws_security_group.application.id

  description                  = "Allow PostgreSQL connections to RDS"
  referenced_security_group_id = aws_security_group.database.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "application_dns_udp" {
  security_group_id = aws_security_group.application.id

  description = "Allow DNS resolution over UDP inside the VPC"
  cidr_ipv4   = var.vpc_cidr
  from_port   = 53
  to_port     = 53
  ip_protocol = "udp"
}

resource "aws_vpc_security_group_egress_rule" "application_dns_tcp" {
  security_group_id = aws_security_group.application.id

  description = "Allow DNS resolution over TCP inside the VPC"
  cidr_ipv4   = var.vpc_cidr
  from_port   = 53
  to_port     = 53
  ip_protocol = "tcp"
}

# ---------------------------------------------------------------------------
# DATABASE RULES
# ---------------------------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "database_postgresql" {
  security_group_id = aws_security_group.database.id

  description                  = "Allow PostgreSQL only from application server"
  referenced_security_group_id = aws_security_group.application.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

# No database egress rule is required. The database accepts PostgreSQL
# connections from the application but does not initiate application traffic.