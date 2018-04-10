data "aws_vpc" "vpc" {
  tags { Name = "${var.env}_vpc" }
}

data "aws_security_group" "bastion_security_group" {
  name = "${var.env}_bastion_sg"
}

resource "aws_security_group" "app_security_group" {
  vpc_id      = "${data.aws_vpc.vpc.id}"
  name        = "${var.app_security_group_name}"
  description = "${var.app_security_group_name}"
  tags { Name = "${var.app_security_group_name}" }
}

# Bastion -> App
resource "aws_security_group_rule" "from_bastion_to_app_egress_security_rule" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${data.aws_security_group.bastion_security_group.id}"
  source_security_group_id = "${aws_security_group.app_security_group.id}"
}

resource "aws_security_group_rule" "from_bastion_to_app_ingress_security_rule" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.app_security_group.id}"
  source_security_group_id = "${data.aws_security_group.bastion_security_group.id}"
}

# App -> DB
resource "aws_security_group_rule" "from_app_to_db_ingress_security_rule" {
  type                     = "ingress"
  from_port                = "${var.db_port}"
  to_port                  = "${var.db_port}"
  protocol                 = "tcp"
  security_group_id        = "${var.db_security_group_id}"
  source_security_group_id = "${aws_security_group.app_security_group.id}"
}

# App -> DB
resource "aws_security_group_rule" "from_app_to_db_egress_security_rule" {
  type                     = "egress"
  from_port                = "${var.db_port}"
  to_port                  = "${var.db_port}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.app_security_group.id}"
  source_security_group_id = "${var.db_security_group_id}"
}

