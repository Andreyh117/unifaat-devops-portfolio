terraform {
  required_version = ">= 1.5, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    encrypt        = true
    key            = "aula-05/terraform.tfstate"
    dynamodb_table = "technova-tf-lock-6325231"
    region         = "us-east-1"
  }
}
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = "TechNova"
      Environment = "development"
      ManagedBy   = "Terraform"
      Owner       = "6325231"
      Aula        = "05"
    }
  }
}
