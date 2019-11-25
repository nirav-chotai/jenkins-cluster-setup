##################################################################################
# Resources
##################################################################################

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = "${data.aws_availability_zones.available.names}"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  instance_tenancy     = "${var.instance_tenancy}"
  tags                 = "${merge(var.tags, map("Name", var.vpc_name))}"
}

resource "aws_subnet" "public" {
  count             = "${var.public_subnet_count}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr, 8, count.index + 10)}"
  availability_zone = "${element(local.azs, count.index)}"
  tags              = "${merge(var.tags, map("Name", format("%s-VPC/subnet/public/%s", var.vpc_name, element(local.azs, count.index))))}"
}

resource "aws_subnet" "private" {
  count             = "${var.private_subnet_count}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr, 8, count.index + 20)}"
  availability_zone = "${element(local.azs, count.index)}"
  tags              = "${merge(var.tags, map("Name", format("%s-VPC/subnet/private/%s", var.vpc_name, element(local.azs, count.index))))}"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", format("%s-igw", var.vpc_name)))}"
}

resource "aws_eip" "nateip" {
  vpc   = true
  tags  = "${merge(var.tags, map("Name", format("%s-eip", var.vpc_name)))}"
}

# To create a NAT gateway, you must specify the public subnet in which the NAT gateway will reside.
# It's recommended to denote that the NAT Gateway depends on the Internet Gateway for the VPC in which the NAT Gateway's subnet is located.

resource "aws_nat_gateway" "natgw" {
  allocation_id = "${aws_eip.nateip.id}"
  subnet_id     = "${element(aws_subnet.public.*.id, 1)}"
  depends_on    = ["aws_internet_gateway.igw"]
  tags          = "${merge(var.tags, map("Name", format("%s-natgw", var.vpc_name)))}"
}

resource "aws_route_table" "public" {
  vpc_id           = "${aws_vpc.vpc.id}"
  tags             = "${merge(var.tags, map("Name", format("%s-rt-public", var.vpc_name)))}"
}

resource "aws_route_table" "private" {
  count                 = "${var.private_subnet_count}"
  vpc_id                = "${aws_vpc.vpc.id}"
  tags                  = "${merge(var.tags, map("Name", format("%s-rt-private-%s", var.vpc_name, count.index)))}"
}

# Inconsistent aws_route behavior when using NAT gateways
# https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/102
# The trick is to set custom timeouts for create on all aws_route resources.

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "private_nat_gateway" {
  count                  = "${var.private_subnet_count}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.natgw.*.id, count.index)}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${var.public_subnet_count}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${var.private_subnet_count}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
