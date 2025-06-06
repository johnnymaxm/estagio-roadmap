terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.98.0"
    }
  }
  backend "s3" {
    bucket         = "state-estagio"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt = true
  }
  required_version = ">= 1.9.0"
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "dev"
      Owner       = "Estagio"
      ManagedBy   = "Terraform"
    }
  }
}