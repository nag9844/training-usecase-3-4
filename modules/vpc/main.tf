# VPC Module - Creates the VPC, subnets, and related networking components

resource "aws_vpc" "demo-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.project_tags,
    {
      Name = "demo-vpc"
    }
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.demo-vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.project_tags,
    {
      Name = "public-subnet-${count.index + 1}"
      Type = "Public"
    }
  )
}


# Internet Gateway
resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = merge(
    var.project_tags,
    {
      Name = "demo-vpc-igw"
    }
  )
}


# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }

  tags = merge(
    var.project_tags,
    {
      Name = "public-route-table"
    }
  )
}


# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
