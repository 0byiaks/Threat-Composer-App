# Application Load Balancer
resource "aws_alb" "alb" {
  name = "${var.environment}-${var.project_name}-alb"
  internal = false
  load_balancer_type = var.load_balancer_type
  security_groups = var.security_groups
  subnets = var.public_subnet_ids

  tags = {
    Name = "${var.environment}-${var.project_name}-alb"
  }
}

# Target Group
resource "aws_alb_target_group" "alb_target_group" {
  name = "${var.environment}-${var.project_name}-alb-tg"
  port = 80
  target_type = var.target_type
  protocol = "HTTP"
  vpc_id = var.vpc_id
  health_check {
    path = "/"
    port = 80
    protocol = "HTTP"
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 3
    interval = 30
  }

  tags = {
    Name = "${var.environment}-${var.project_name}-alb-target-group"
  }
}

# ALB HTTP to HTTPS redirect
resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ALB HTTPS Listener
resource "aws_alb_listener" "alb_listener_https" {
  load_balancer_arn = aws_alb.alb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = var.certificate_arn
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group.arn
  }
}

