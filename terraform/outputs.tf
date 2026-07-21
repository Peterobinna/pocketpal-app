# VPC identifier used by the PocketPal infrastructure.
output "vpc_id" {
  description = "ID of the PocketPal VPC"
  value       = aws_vpc.main.id
}

# Public subnet identifier.
output "public_subnet_id" {
  description = "ID of the PocketPal public subnet"
  value       = aws_subnet.public.id
}

# Internet gateway identifier.
output "internet_gateway_id" {
  description = "ID of the VPC internet gateway"
  value       = aws_internet_gateway.main.id
}

# Public route-table identifier.
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

# Application security-group identifier.
output "security_group_id" {
  description = "ID of the PocketPal EC2 security group"
  value       = aws_security_group.pocketpal.id
}

# EC2 instance identifier.
output "instance_id" {
  description = "ID of the PocketPal EC2 instance"
  value       = aws_instance.pocketpal.id
}

# Public IPv4 address used to access the server.
output "instance_public_ip" {
  description = "Public IPv4 address of the PocketPal EC2 instance"
  value       = aws_instance.pocketpal.public_ip
}

# Public DNS hostname assigned to the server.
output "instance_public_dns" {
  description = "Public DNS name of the PocketPal EC2 instance"
  value       = aws_instance.pocketpal.public_dns
}

# Availability zone selected for the public subnet.
output "availability_zone" {
  description = "Availability zone containing the PocketPal server"
  value       = aws_subnet.public.availability_zone
}

# Ubuntu AMI selected dynamically for the deployment.
output "ubuntu_ami_id" {
  description = "ID of the Ubuntu AMI selected for the EC2 instance"
  value       = data.aws_ami.ubuntu.id
}

# Command that can be used to connect to the instance.
output "ssh_command" {
  description = "Example SSH command for connecting to the PocketPal server"
  value       = "ssh -i ~/.ssh/${var.ssh_key_name}.pem ubuntu@${aws_instance.pocketpal.public_ip}"
}

# URLs for testing the deployed containers after Ansible configuration.
output "application_urls" {
  description = "PocketPal application URLs after Ansible deployment"
  value = {
    frontend = "http://${aws_instance.pocketpal.public_ip}:${var.frontend_port}"
    backend  = "http://${aws_instance.pocketpal.public_ip}:${var.backend_port}"
  }
}