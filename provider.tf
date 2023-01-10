terraform {
#  required_version = "~>0.14.3"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>2.50.0"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  profile = "default"
}
