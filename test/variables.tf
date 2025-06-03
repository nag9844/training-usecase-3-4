variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default = "demo-key"
}
 
variable "ami_id" {
  description = "AMI ID for EC2 (Amazon Linux 2)"
  type        = string
  default = "ami-0f535a71b34f2d44a"
}