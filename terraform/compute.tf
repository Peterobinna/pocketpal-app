resource "aws_instance" "bastion" {
  # checkov:skip=CKV_AWS_88:The bastion is intentionally placed in a public subnet and requires a public IP to act as the controlled SSH jump host.
  # checkov:skip=CKV2_AWS_41:The bastion does not call AWS APIs, so attaching an IAM role would introduce unnecessary permissions.

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_1.id
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion.id]

  # Improve EBS performance and satisfy the EC2 security baseline.
  ebs_optimized = true

  # Enable detailed EC2 monitoring.
  monitoring = true

  # Require IMDSv2 to protect EC2 instance metadata.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
  }

  tags = {
    Name = "${local.resource_prefix}-bastion"
  }
}

resource "aws_instance" "application" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.application.id
  key_name                    = var.ssh_key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.application.id]
  iam_instance_profile        = aws_iam_instance_profile.application.name

  # Improve EBS performance and satisfy the EC2 security baseline.
  ebs_optimized = true

  # Enable detailed EC2 monitoring.
  monitoring = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
  }

  depends_on = [aws_nat_gateway.main]

  tags = {
    Name = "${local.resource_prefix}-application"
  }
}