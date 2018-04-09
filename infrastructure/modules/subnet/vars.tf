variable "vpc_id" {}
variable "number_of_subnets" { default = 2 }
variable "cidr_blocks" { type = "map" }
variable "map_public_ip_on_launch" {}
variable "name" {}
variable "zones" {
  default = {
    zone_0 = "eu-west-2a"
    zone_1 = "eu-west-2b"
  }
}
