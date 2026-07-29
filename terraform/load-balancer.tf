resource "aws_lb" "main" {
  # checkov:skip=CKV2_AWS_28:AWS WAF is outside the cost and scope of this coursework environment. A production deployment should attach a managed WAF web ACL.

  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  # Reject malformed HTTP headers before they reach the application.
  drop_invalid_header_fields = true

  tags = {
    Name = "${local.resource_prefix}-alb"
  }
}

resource "aws_lb_target_group" "frontend" {
  # checkov:skip=CKV_AWS_378:Traffic between the ALB and application EC2 remains inside the private VPC. Production should use end-to-end TLS where required.

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
  # checkov:skip=CKV_AWS_378:Traffic between the ALB and application EC2 remains inside the private VPC. Production should use end-to-end TLS where required.

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
  # checkov:skip=CKV_AWS_103:The coursework environment does not currently have a domain and ACM certificate. Production must use TLS 1.2 or newer and redirect HTTP to HTTPS.

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