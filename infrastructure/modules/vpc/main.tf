resource "aws_vpc" "vpc" {
    cidr_block           = "${var.vpc_cidr}"
    enable_dns_hostnames = "${var.enable_dns_hostnames}"
    tags { Name = "${var.vpc_name}" }
}

# Create an internet gateway
resource "aws_internet_gateway" "ig" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags { Name = "${var.ig_name}" }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access_route" {
  route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "${var.route_destination_cidr_block}"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}

