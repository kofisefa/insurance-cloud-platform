#############################################
# VPC
#############################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

#############################################
# Internet Gateway
#############################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

#############################################
# Public Subnet 1
#############################################

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_1
  availability_zone       = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-1"

    "kubernetes.io/cluster/insurance-dev-eks" = "shared"
    "kubernetes.io/role/elb"                  = "1"
  }
}

#############################################
# Public Subnet 2
#############################################

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_2
  availability_zone       = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-2"

    "kubernetes.io/cluster/insurance-dev-eks" = "shared"
    "kubernetes.io/role/elb"                  = "1"
  }
}

#############################################
# Public Route Table
#############################################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

#############################################
# Route Table Associations
#############################################

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}