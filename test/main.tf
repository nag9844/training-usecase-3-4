provider "aws" {
  region = "us-east-1"
}
 
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
 
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
}
 
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}
 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
 
resource "aws_route_table_association" "a" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}
 
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id
 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 
resource "aws_launch_template" "openproject" {
  name_prefix   = "openproject-"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name
 
  user_data = filebase64("user_data_openproject.sh")
 
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sg.id]
    subnet_id                   = aws_subnet.public[0].id
  }
}
 
resource "aws_launch_template" "devlake" {
  name_prefix   = "devlake-"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name
 
  user_data = filebase64("user_data_devlake.sh")
 
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sg.id]
    subnet_id                   = aws_subnet.public[1].id
  }
}
 
resource "aws_instance" "openproject" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = file("user_data_openproject.sh")
}
 
resource "aws_instance" "devlake" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[1].id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = file("user_data_devlake.sh")
}
 
resource "aws_lb" "alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.web_sg.id]
}
 
resource "aws_lb_target_group" "openproject" {
  name     = "tg-openproject"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"
}
 
resource "aws_lb_target_group" "devlake" {
  name     = "tg-devlake"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"
}
 
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
 
  default_action {
    type = "fixed-response"
 
    fixed_response {
      content_type = "text/plain"
      message_body = "Invalid Path"
      status_code  = "404"
    }
  }
}
 
resource "aws_lb_listener_rule" "homepage" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 10
 
  condition {
    path_pattern {
      values = ["/"]
    }
  }
 
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.homepage.arn
  }
}
 
resource "aws_lb_listener_rule" "openproject" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 20
 
  condition {
    path_pattern {
      values = ["/openproject*"]
    }
  }
 
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.openproject.arn
  }
}
 
resource "aws_lb_listener_rule" "devlake" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 30
 
  condition {
    path_pattern {
      values = ["/devlake*"]
    }
  }
 
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.devlake.arn
  }
}
 
resource "aws_lb_target_group_attachment" "tg_attach_openproject" {
  target_group_arn = aws_lb_target_group.openproject.arn
  target_id        = aws_instance.openproject.id
  port             = 8080
}
 
resource "aws_lb_target_group_attachment" "tg_attach_devlake" {
  target_group_arn = aws_lb_target_group.devlake.arn
  target_id        = aws_instance.devlake.id
  port             = 8080
}
 
variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}
 
variable "ami_id" {
  description = "AMI ID for EC2 (Amazon Linux 2)"
  type        = string
}
 