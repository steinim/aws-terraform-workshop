variable "nat_gateway_enabled" {
    description = "set to 1 to create nat gateway instances for private subnets"
    default = 0
}
variable "public_subnet_ids" { type = "list" }
variable "nat_eip_allocation_id" {}
