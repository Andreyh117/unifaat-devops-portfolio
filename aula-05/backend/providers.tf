terraform {
  required_version = ">= 1.5, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = { Project = "TechNova", Aula = "05", Owner = "6325231", ManagedBy = "Terraform" }
  }
}
