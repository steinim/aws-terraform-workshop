# NAT instance with elastic ip

resource "aws_nat_gateway" "nat" {
  count         = "1"
  allocation_id = "${var.nat_eip_allocation_id}"
  subnet_id     = "${var.public_subnet_ids[0]}"
}

