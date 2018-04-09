resource "aws_security_group" "bastion_sg" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.env}_bastion_sg"
  tags { Name = "${var.env}_bastion_sg" }
}

resource "aws_security_group_rule" "ssh_ingress_rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_block}"]
  security_group_id = "${aws_security_group.bastion_sg.id}"
}

