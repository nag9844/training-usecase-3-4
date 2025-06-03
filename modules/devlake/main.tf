resource "aws_instance" "devlake" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.public_subnet_ids[1]

  #user_data = templatefile("${path.module}/user_data.sh", {})

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    curl -fsSL https://get.docker.com -o install-docker.sh
    sudo sh install-docker.sh
    sudo usermod -aG docker ubuntu
    mkdir -p ~/devlake
    cd ~/devlake
    cat > docker-compose.yml << 'EOL'
    version: '3'
    
    services:
      devlake:
        image: devlake/devlake:latest
        ports:
          - "4000:4000"
        environment:
          - DEVLAKE_DB_HOST=mysql
          - DEVLAKE_DB_PORT=3306
          - DEVLAKE_DB_USER=root
          - DEVLAKE_DB_PASSWORD=secret
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
    Name = "devlake-instance"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
}