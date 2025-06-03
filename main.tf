terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.10.0"
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  project_tags         = var.project_tags
}

module "security" {
  source = "./modules/security"
  
  vpc_id       = module.vpc.vpc_id
  project_tags = var.project_tags
}

module "compute" {
  source            = "./modules/compute"
  instance_count    = 1
  ami               = var.ami
  instance_type     = var.instance_type
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.security.web_security_group_id
  user_data         = <<-EOF
                      #!/bin/bash
                      sudo apt update -y
                      sudo apt install -y nginx 
                      sudo systemctl start nginx
                      sudo systemctl enable nginx
                      HOSTNAME=$(hostname)
                      echo '<html><body><h1>Hostname: '"$HOSTNAME"'</h1></body></html>' > /usr/share/nginx/html/index.html
                      sudo systemctl restart nginx
                      EOF
  project_tags = var.project_tags
}

module "alb" {
  source = "./modules/alb"
  
  vpc_id            = module.vpc.vpc_id
  public_subnets    = module.vpc.public_subnet_ids
  alb_sg_id         = module.security.alb_security_group_id
  project_tags      = var.project_tags
  
  target_groups = {
    homepage = {
      name = "homepage"
      path = "/"
      port = 80
    }
    openproject = {
      name = "openproject"
      path = "/openproject*"
      port = 80
    }
    devlake = {
      name = "devlake"
      path = "/devlake*"
      port = 80
    }
  }
}

module "compute" {
  source = "./modules/compute"
  
  vpc_id                  = module.vpc.vpc_id
  private_subnets         = module.vpc.private_subnet_ids
  instance_security_group = module.security.instance_security_group_id
  project_tags            = var.project_tags
  
  target_group_arns = {
    homepage = module.load_balancer.target_group_arns["homepage"]
    openproject   = module.load_balancer.target_group_arns["openproject"]
    devlake = module.load_balancer.target_group_arns["devlake"]
  }
  
  instances = {
    homepage = {
      name         = "homepage-instance"
      subnet_index = 0
      user_data    = <<-EOF
                     #!/bin/bash
                     apt-get update
                     apt-get install -y nginx
                     systemctl start nginx
                     systemctl enable nginx
                     cat > /var/www/html/index.html << 'EOT'
                     <!DOCTYPE html>
                     <html>
                     <head>
                         <title>Homepage</title>
                     </head>
                     <body>
                         <h1>Homepage!</h1>
                         <p>Instance A</p>
                         <ul>
                             <li><a href="/openproject">Go to openproject</a></li>
                             <li><a href="/devlake">Go to devlake</a></li>
                         </ul>
                     </body>
                     </html>
                     EOT
                     EOF
    }
    openproject = {
      name         = "openproject-instance"
      subnet_index = 1
      user_data    = <<-EOT
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker run -dit -p 80:80 -e OPENPROJECT_SECRET_KEY_BASE=secret -e OPENPROJECT_HOST__NAME=0.0.0.0:80 -e OPENPROJECT_HTTPS=false openproject/community:12
              EOT
    }
    devlake = {
      name         = "devlake-instance"
      subnet_index = 2
      user_data    = <<-EOT
                     #!/bin/bash
                     apt-get update -y
                     apt-get install -y docker.io
                     systemctl start docker
                     git clone https://github.com/nag9844/training-usecase-3-4.git
                     cd training-usecase-3-4
                     curl -SL https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
                     chmod +x /usr/local/bin/docker-compose
                     docker-compose up -d
                     EOT
    }
  }
}