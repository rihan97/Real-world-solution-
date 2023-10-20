provider "aws" {
  aws = {
    version    = "~> 5.0"
    region     = "eu-west-2"
    access_key = ""
    secret_key = ""
  }
  kubernetes = {
    version = ">= 2.10"
  }
}