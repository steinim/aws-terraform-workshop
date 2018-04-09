resource "aws_subnet" "subnet" {
  vpc_id                  = "${var.vpc_id}"
  count                   = "${var.number_of_subnets}"
  cidr_block              = "${lookup(var.cidr_blocks, "zone_${count.index}")}"
  availability_zone       = "${lookup(var.zones, "zone_${count.index}")}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags { Name = "${var.name}_subnet_${lookup(var.zones, "zone_${count.index}")}" }
}

