# provider "aws" {
#   aws = {
#     version    = "~> 5.0"
#     region     = "eu-west-1"
#     access_key = "AKIAU7GNFBVE7LGMVN5L"
#     secret_key = "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"
#   }
#   kubernetes = {
#     version = ">= 2.10"
#   }
# }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}