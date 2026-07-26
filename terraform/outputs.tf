output "vpc_id" {
  value = aws_vpc.main.id
}

output "bastion_public_ip" {
  description = "Public IP used as the Ansible jump host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_security_group_id" {
  description = "Used by CD for temporary GitHub runner SSH access"
  value       = aws_security_group.bastion.id
}

output "application_private_ip" {
  description = "Private application server IP"
  value       = aws_instance.application.private_ip
}

output "frontend_ecr_repository_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "backend_ecr_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "database_endpoint" {
  value     = aws_db_instance.main.endpoint
  sensitive = true
}

output "load_balancer_dns" {
  value = aws_lb.main.dns_name
}

output "live_application_url" {
  value = "http://${aws_lb.main.dns_name}"
}

output "health_check_url" {
  value = "http://${aws_lb.main.dns_name}/health"
}