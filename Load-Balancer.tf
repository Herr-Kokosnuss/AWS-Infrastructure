# Data sources for AWS region and account ID
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

#Amazon's Elastic Load Balancer (ELB)
resource "aws_lb" "Cocoplanner" {
  name               = "Cocoplanner"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb.id]
}

# create a target group for ASG
resource "aws_lb_target_group" "asg" {
  name     = "Cocoplanner"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200,301,302"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 4
  }
}

# HTTP Listener - Redirect to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.Cocoplanner.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener - Forward to target group
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.Cocoplanner.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:certificate/c6475e8c-127f-4d84-8641-e4cfc75e99fa"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
} 