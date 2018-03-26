variable "aws_region" {}
variable "vpc_name" {}
variable "enable_dns_hostnames" { default = "true" }
variable "ig_name" {}
variable "vpc_cidr" {}
variable "route_destination_cidr_block" { default = "0.0.0.0/0" }
