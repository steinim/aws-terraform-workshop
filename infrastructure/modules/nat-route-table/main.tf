resource "aws_route_table" "nat_route_table" {
    vpc_id      = "${var.vpc_id}"
    tags { Name = "${var.env}_nat_gateway_route_table" }
}

resource "aws_route" "default_route" {
  route_table_id            = "${aws_route_table.nat_route_table.id}"
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = "${var.nat_id}"
}
