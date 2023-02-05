terraform {
  backend "s3" {
    bucket = "ogunmolabucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}