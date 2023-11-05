terraform {
  backend "s3" {
    bucket = "terraformoutputs"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}