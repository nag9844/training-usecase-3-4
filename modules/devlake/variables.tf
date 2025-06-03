variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs to associate with the instance"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair to use"
  type        = string
  default     = null
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}