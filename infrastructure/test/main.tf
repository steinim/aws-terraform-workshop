provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source     = "../modules/vpc"
  aws_region = "${var.region}"
  vpc_name   = "${var.env}_vpc"
  vpc_cidr   = "10.0.0.0/16"
  ig_name    = "${var.env}_ig"
}

module "public_subnets" {
  source                  = "../modules/subnet"
  vpc_id                  = "${module.vpc.vpc_id}"
  cidr_blocks             = "${var.public_subnets_cidr_blocks}"
  name                    = "${var.env}_public"
  map_public_ip_on_launch = "true"
}

module "public_ig_route_table" {
  source              = "../modules/ig-route-table"
  internet_gateway_id = "${module.vpc.internet_gateway_id}"
  vpc_id              = "${module.vpc.vpc_id}"
  env                 = "${var.env}"
}

module "public_route_table_association" {
  source         = "../modules/route-table-association"
  subnet_ids     = ["${module.public_subnets.subnet_ids}"]
  route_table_id = "${module.public_ig_route_table.internet_gateway_route_table_id}"
}

module "private_subnets" {
  source                  = "../modules/subnet"
  vpc_id                  = "${module.vpc.vpc_id}"
  cidr_blocks             = "${var.private_subnets_cidr_blocks}"
  name                    = "${var.env}_private"
  map_public_ip_on_launch = "false"
}

module "nat" {
  source                = "../modules/nat"
  nat_eip_allocation_id = "${var.nat_eip_allocation_id}"
  public_subnet_ids     = ["${module.public_subnets.subnet_ids}"]
}

module "private_nat_route_table" {
  source = "../modules/nat-route-table"
  nat_id = "${module.nat.nat_id}"
  vpc_id = "${module.vpc.vpc_id}"
  env    = "${var.env}"
}

module "private_route_table_association" {
  source         = "../modules/route-table-association"
  subnet_ids     = ["${module.private_subnets.subnet_ids}"]
  route_table_id = "${module.private_nat_route_table.nat_route_table_id}"
}

module "security_groups" {
  source     = "../modules/security-groups"
  vpc_id     = "${module.vpc.vpc_id}"
  env        = "${var.env}"
  cidr_block = "0.0.0.0/0"
}

module "key_pair" {
  source     = "../modules/key-pair"
  key_name   = "${var.env}"
  public_key = "${var.public_key}"
}

module "bastion" {
  source                      = "../modules/instance"
  name                        = "${var.env}_bastion"
  ami                         = "${var.bastion_ami}"
  instance_type               = "t2.nano"
  key_pair_id                 = "${module.key_pair.id}"
  subnet_id                   = "${element(module.public_subnets.subnet_ids, 0)}"
  associate_public_ip_address = "${var.bastion_associate_public_ip_address}"
  security_group_id           = "${module.security_groups.bastion_sg_id}"
  source_dest_check           = "false"
}
