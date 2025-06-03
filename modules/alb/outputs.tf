output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "openproject_target_group_arn" {
  description = "The ARN of the OpenProject target group"
  value       = aws_lb_target_group.openproject.arn
}

output "devlake_target_group_arn" {
  description = "The ARN of the DevLake target group"
  value       = aws_lb_target_group.devlake.arn
}