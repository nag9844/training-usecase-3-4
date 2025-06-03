resource "aws_lb" "main" {
  name               = "docker-apps-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "docker-apps-alb"
  }
}

resource "aws_lb_target_group" "openproject" {
  name     = "openproject-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
}

resource "aws_lb_target_group" "devlake" {
  name     = "devlake-target-group"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
}

resource "aws_lb_target_group_attachment" "openproject" {
  target_group_arn = aws_lb_target_group.openproject.arn
  target_id        = var.openproject_instance
  port             = 8080
}

resource "aws_lb_target_group_attachment" "devlake" {
  target_group_arn = aws_lb_target_group.devlake.arn
  target_id        = var.devlake_instance
  port             = 4000
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Please use /openproject or /devlake path"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "openproject" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.openproject.arn
  }

  condition {
    path_pattern {
      values = ["/openproject*"]
    }
  }
}

resource "aws_lb_listener_rule" "devlake" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.devlake.arn
  }

  condition {
    path_pattern {
      values = ["/devlake*"]
    }
  }
}