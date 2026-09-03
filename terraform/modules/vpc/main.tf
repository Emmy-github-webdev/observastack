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

###########################
# Public Subnets
###########################
resource "aws_subnet" "pub_subnet" {
  for_each = {
    for index, az in var.availability_zones :
    az => index
  }

  vpc_id                  = aws_vpc.observastack_vpc.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, each.value)
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name                     = "${local.name_prefix}-public-${each.key}"
      Tier                     = "public"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

############################
# Private application subnets
############################
resource "aws_subnet" "priv_subnet" {
  for_each = {
    for index, az in var.availability_zones :
    az => index
  }

  vpc_id            = aws_vpc.observastack_vpc.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, each.value + 4)

  tags = merge(
    local.common_tags,
    {
      Name                              = "${local.name_prefix}-private-${each.key}"
      Tier                              = "private"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

#############################
# Database subnets
#############################
resource "aws_subnet" "database" {
  for_each = {
    for index, az in var.availability_zones :
    az => index
  }

  vpc_id            = aws_vpc.observastack_vpc.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, each.value + 8)

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-database-${each.key}"
      Tier = "database"
    }
  )
}