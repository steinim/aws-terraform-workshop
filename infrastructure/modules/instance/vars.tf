variable "name" {}
variable "ami" {}
variable "instance_type" { default = "t2.micro" }
variable "key_pair_id" {}
variable "subnet_id" {}
variable "associate_public_ip_address" { default = false }
variable "source_dest_check" { default = true }
variable "security_group_id" {}
