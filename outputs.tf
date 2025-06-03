# Output values from the Terraform configuration

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}


output "alb_dns_name" {
    description = "alb dns name"
    value = module.alb.alb_dns_name
}