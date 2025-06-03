resource "aws_instance" "openproject" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.public_subnet_ids[0]

  user_data = templatefile("${path.module}/user_data.sh", {})

  tags = {
    Name = "openproject-instance"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
}