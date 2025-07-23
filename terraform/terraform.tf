terraform {
  backend "s3" {
    bucket = "synchronet-bbs"
    key    = "terraform-sbbs/terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Comment = "Created Terraform"
      Repo    = "Synchronet BBS"
    }
  }
}
