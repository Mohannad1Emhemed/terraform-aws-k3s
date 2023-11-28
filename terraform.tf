terraform {
  cloud {
    organization = "Mohannad-Terraform"
    workspaces {
      name = "AWS-K8s-RDS-EC2"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"

}