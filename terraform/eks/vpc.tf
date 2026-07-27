data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )

  public_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 1),
    cidrsubnet(var.vpc_cidr, 8, 2)
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs            = local.availability_zones
  public_subnets = local.public_subnets

  enable_dns_support   = true
  enable_dns_hostnames = true

  # Cost-conscious lab configuration:
  # no private subnets and no managed NAT Gateway.
  enable_nat_gateway = false

  # Worker nodes launched in these public subnets receive public IPv4
  # addresses so they can pull container images from external registries.
  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}