terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # locks to 6.x, won't jump to 7.x
    }
  }
  required_version = ">= 1.0"
}
provider "aws" {
  region = "us-east-1"
}