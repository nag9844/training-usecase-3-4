# Variables for the main Terraform configuration

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/23"
}

variable "availability_zones" {
  description = "List of availability zones to use for the subnets"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/28", "10.0.2.0/28"]
}


variable "ami" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0e35ddab05955cf57"
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t3.medium"
}


variable "project_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "web-tier-2"
    Environment = "Development"
    Terraform   = "true"
  }
}