output "nat_id" {
  value = "${aws_nat_gateway.nat.id}"
}

output "public_ip" {
  value = "${aws_nat_gateway.nat.public_ip}"
}
