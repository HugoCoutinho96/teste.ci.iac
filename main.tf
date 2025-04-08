terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }

  backend "s3" {
    bucket = "projeto-iac-state"
    key    = "state/terraform.tfstate"
    region = "eu-central-1"
  }

}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "terraform-state" {
  bucket        = "projeto-iac-state"
  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Iac = true
  }
}

resource "aws_s3_bucket_versioning" "terraform-state" {
  bucket = "projeto-iac-state"

  versioning_configuration {
    status = "Enabled"
  }
}