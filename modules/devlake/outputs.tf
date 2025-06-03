output "instance_id" {
  description = "The ID of the DevLake EC2 instance"
  value       = aws_instance.devlake.id
}

output "private_ip" {
  description = "The private IP of the DevLake EC2 instance"
  value       = aws_instance.devlake.private_ip
}

output "public_ip" {
  description = "The public IP of the DevLake EC2 instance"
  value       = aws_instance.devlake.public_ip
}