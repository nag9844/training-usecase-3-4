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
