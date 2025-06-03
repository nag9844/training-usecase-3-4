output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "openproject_instance_id" {
  description = "The ID of the OpenProject EC2 instance"
  value       = module.openproject.instance_id
}

output "devlake_instance_id" {
  description = "The ID of the DevLake EC2 instance"
  value       = module.devlake.instance_id
}


output "openproject_url" {
  description = "URL to access OpenProject through ALB"
  value       = "http://${module.alb.openproject_dns_name}"
}

output "devlake_url" {
  description = "URL to access DevLake through ALB"
  value       = "http://${module.alb.devlake_dns_name}"
}