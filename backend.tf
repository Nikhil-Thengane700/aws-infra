# backend.tf
terraform {
  backend "s3" {
    bucket       = "aws-infra-tf-state789"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}


