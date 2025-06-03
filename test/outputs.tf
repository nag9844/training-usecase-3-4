variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}
 
variable "ami_id" {
  description = "AMI ID for EC2 (Amazon Linux 2)"
  type        = string
}