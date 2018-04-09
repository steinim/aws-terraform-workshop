resource "aws_route_table" "internet_gateway_route_table" {
    vpc_id      = "${var.vpc_id}"

    route {
        cidr_block     = "${var.cidr_block}"
        gateway_id = "${var.internet_gateway_id}"
    }

    tags { Name = "${var.env}_internet_gateway_route_table" }
}

