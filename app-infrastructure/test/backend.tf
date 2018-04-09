terraform {
  backend "s3" {
    bucket = "terraform-state-sim"
    key    = "infrastructure/test/hello/terraform.tfstate"
    region = "eu-west-2"
  }
}
