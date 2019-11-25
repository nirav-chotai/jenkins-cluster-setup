##################################################################################
# OUTPUT
##################################################################################

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}

output "public_subnets_cidr" {
  value = ["${aws_subnet.public.*.cidr_block}"]
}

output "public_subnets_azs" {
  value = ["${aws_subnet.public.*.availability_zone}"]
}

output "public_route_table_ids" {
  value = ["${aws_route_table.public.*.id}"]
}

output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}

output "private_subnets_cidr" {
  value = ["${aws_subnet.private.*.cidr_block}"]
}

output "private_subnets_azs" {
  value = ["${aws_subnet.private.*.availability_zone}"]
}

output "private_route_table_ids" {
  value = ["${aws_route_table.private.*.id}"]
}

output "igw_id" {
  value = "${aws_internet_gateway.igw.id}"
}

output "nat_eips_id" {
  value = ["${aws_eip.nateip.*.id}"]
}

output "nat_eips_public_ips" {
  value = ["${aws_eip.nateip.*.public_ip}"]
}

output "natgw_id" {
  value = "${aws_nat_gateway.natgw.id}"
}
