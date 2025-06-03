resource "aws_instance" "openproject" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.public_subnet_ids[0]

  #user_data = templatefile("${path.module}/user_data.sh", {})

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    curl -fsSL https://get.docker.com -o install-docker.sh
    sudo sh install-docker.sh
    sudo usermod -aG docker ubuntu
    mkdir -p ~/openproject
    cd ~/openproject
    cat > docker-compose.yml << 'EOL'
    version: '3'

    services:
      openproject:
        image: openproject/community:latest
        ports:
          - "8080:8080"
        environment:
          - DATABASE_URL=mysql2://root:secret@mysql:3306/openproject
        depends_on:
          - mysql

      mysql:
        image: mysql:5.7
        environment:
          MYSQL_ROOT_PASSWORD: secret
        volumes:
          - db_data:/var/lib/mysql

    volumes:
      db_data:
    EOL

    docker-compose up -d
  EOF

  tags = {
    Name = "openproject-instance"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
}