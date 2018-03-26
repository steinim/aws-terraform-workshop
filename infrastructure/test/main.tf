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

