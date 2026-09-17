data "aws_availability_zones" "available" {
  state = "available"
}
locals {
  subnets = {
    public_a  = { cidr = "10.0.1.0/24", az = 0, public = true }
    private_a = { cidr = "10.0.2.0/24", az = 0, public = false }
    public_b  = { cidr = "10.0.3.0/24", az = 1, public = true }
    private_b = { cidr = "10.0.4.0/24", az = 1, public = false }
  }
}
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "technova-vpc" }
}
resource "aws_subnet" "main" {
  for_each                = local.subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = data.aws_availability_zones.available.names[each.value.az]
  map_public_ip_on_launch = each.value.public
  tags                    = { Name = "technova-${each.key}" }
}
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "technova-igw" }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "technova-public-rt" }
}
resource "aws_route_table_association" "public" {
  for_each       = { for k, v in local.subnets : k => v if v.public }
  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.public.id
}
resource "aws_default_route_table" "private" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  route                  = []
  tags                   = { Name = "technova-private-default-rt" }
}
