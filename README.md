# AWS Docker Applications Infrastructure with Terraform

This project provides Terraform configurations to deploy a VPC with two public subnets and EC2 instances running Docker applications (OpenProject and DevLake) with an Application Load Balancer for path-based routing.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.2.0 or newer)
- AWS CLI configured with appropriate credentials
- SSH key pair in AWS (optional, for SSH access to instances)

## Architecture

The infrastructure consists of:

- VPC with 2 public subnets across different availability zones
- Internet Gateway for public internet access
- 2 EC2 instances with Docker and Docker Compose installed
- Application Load Balancer with path-based routing
- Security groups for controlled access

## Applications

1. **OpenProject** - Project management software
   - Available at: http://ALB_DNS_NAME/openproject

2. **Apache DevLake** - Developer data platform
   - Available at: http://ALB_DNS_NAME/devlake

## Usage

1. Initialize Terraform:
   ```
   terraform init
   ```

2. Review the execution plan:
   ```
   terraform plan
   ```

3. Apply the configuration:
   ```
   terraform apply
   ```

4. To destroy the infrastructure when no longer needed:
   ```
   terraform destroy
   ```

## Customization

You can customize the deployment by modifying the variables in `variables.tf` or by creating a `terraform.tfvars` file with your specific values:

```hcl
aws_region          = "us-east-1"
vpc_cidr_block      = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
availability_zones  = ["us-east-1a", "us-east-1b"]
instance_type       = "t3.large"
key_name            = "your-key-pair-name"
```

## Important Notes

- The EC2 instances are publicly accessible via SSH if you specified a key pair
- The applications are exposed through the ALB on HTTP (port 80)
- For production use, consider enabling HTTPS with a proper certificate
- Default passwords are set in the user data scripts - change them for production deployments