output "alb_sg_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "instance_sg_id" {
  description = "The ID of the instance security group"
  value       = aws_security_group.instance_sg.id
}