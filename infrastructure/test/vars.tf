variable "region" {}
variable "env" {}
variable "public_subnets_cidr_blocks" {
  default = {
    zone_0 = "10.0.1.0/24"
    zone_1 = "10.0.2.0/24"
  }
}
variable "private_subnets_cidr_blocks" {
  default = {
    zone_0 = "10.0.3.0/24"
    zone_1 = "10.0.4.0/24"
  }
}
variable "nat_eip_allocation_id" { default = "eipalloc-0e7b88a896d2db1e2" } # Substitute with your own eip-id
