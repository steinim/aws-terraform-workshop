resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.db_subnet_group_name}"
  description = "${var.db_subnet_group_name}"
  subnet_ids  = ["${var.private_subnet_ids}"]
}
