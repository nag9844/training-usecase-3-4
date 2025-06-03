output "instance_id" {
  description = "The ID of the OpenProject EC2 instance"
  value       = aws_instance.openproject.id
}

output "private_ip" {
  description = "The private IP of the OpenProject EC2 instance"
  value       = aws_instance.openproject.private_ip
}

output "public_ip" {
  description = "The public IP of the OpenProject EC2 instance"
  value       = aws_instance.openproject.public_ip
}