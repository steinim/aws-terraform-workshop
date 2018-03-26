terraform {
  backend "s3" {
    bucket = "terraform-state-sim"
    key    = "infrastructure/test/terraform.tfstate"
    region = "eu-west-2"
  }
}
