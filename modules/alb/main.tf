resource "aws_lb"  "app_lb_open" {
  name               = "openproject-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.instance_sg.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public_2.id]
}

# ALB for DevLake
resource "aws_lb" "app_lb" {
  name               = "devlake-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.instance_sg.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public_2.id]
}

# ALB Target Groups
resource "aws_lb_target_group" "openproject_tg" {
  name     = "openproject-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group" "devlake_tg" {
  name     = "devlake-tg"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

# ALB Listener & Rules for OpenProject
resource "aws_lb_listener" "listener_openproject" {
  load_balancer_arn = aws_lb.app_lb_open.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.openproject_tg.arn
  }
}

# ALB Listener & Rules for DevLake
resource "aws_lb_listener" "listener_devlake" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.devlake_tg.arn
  }
}
