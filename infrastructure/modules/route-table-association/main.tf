resource "aws_route_table_association" "route-table-association" {
    count          = "${var.number_of_subnets}"
    subnet_id      = "${element(var.subnet_ids, count.index)}"
    route_table_id = "${var.route_table_id}"
}
