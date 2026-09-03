##########################
# VPC
##########################
resource "aws_vpc" "observastack_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

############################
# Internet Gateway
############################
resource "aws_internet_gateway" "observastack_igw" {
  vpc_id = aws_vpc.observastack_vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )
}