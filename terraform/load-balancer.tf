resource "aws_lb" "main" {
  # checkov:skip=CKV2_AWS_28:AWS WAF is outside the cost and scope of this coursework environment. Production must attach a managed WAF web ACL.
  # checkov:skip=CKV_AWS_150:Deletion protection is disabled so the team can destroy billable coursework resources after grading. Production must enable it.
  # checkov:skip=CKV_AWS_91:ALB access logging requires an additional S3 logging architecture and is omitted for this short-lived coursework environment. Production must enable centralized access logs.
  # checkov:skip=CKV2_AWS_20:An HTTPS redirect requires a registered domain and ACM certificate. The coursework environment exposes HTTP only; production must redirect HTTP to HTTPS.

  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  drop_invalid_header_fields = true
  enable_deletion_protection = false

  tags = {
    Name = "${local.resource_prefix}-alb"
  }
}

resource "aws_lb_target_group" "frontend" {
  # checkov:skip=CKV_AWS_378:Traffic between the ALB and the application instance remains inside the controlled VPC. Production should use end-to-end TLS where required.

  name        = "${var.project_name}-frontend-tg"
  port        = var.frontend_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "backend" {
  # checkov:skip=CKV_AWS_378:Traffic between the ALB and the application instance remains inside the controlled VPC. Production should use end-to-end TLS where required.

  name        = "${var.project_name}-backend-tg"
  port        = var.backend_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "frontend" {
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.application.id
  port             = var.frontend_port
}

resource "aws_lb_target_group_attachment" "backend" {
  target_group_arn = aws_lb_target_group.backend.arn
  target_id        = aws_instance.application.id
  port             = var.backend_port
}

resource "aws_lb_listener" "http" {
  # checkov:skip=CKV_AWS_2:The coursework environment has no registered domain or ACM certificate. Production must use HTTPS.
  # checkov:skip=CKV_AWS_103:The coursework environment has no registered domain or ACM certificate. Production must use TLS 1.2 or newer.


  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener_rule" "backend_api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*", "/health"]
    }
  }
}