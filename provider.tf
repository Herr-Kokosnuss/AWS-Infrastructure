# Terraform and provider configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">=1.0.0"
}
locals {
  aws_accounts = {
 
    "dev" = {
      region  = "us-east-1",
      profile = "dev-account"
    },
    "prod" = {
      region  = "us-east-1",
      profile = "prod-account"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = local.aws_accounts[terraform.workspace].region
  profile = local.aws_accounts[terraform.workspace].profile
}
