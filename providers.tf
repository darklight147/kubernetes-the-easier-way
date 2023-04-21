terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.63.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-mysqli" // change this to your bucket name
    key            = "terraform.tfstate"
    region         = "us-east-1"            // change this to your region
    dynamodb_table = "terraform-state-lock" // change this to your table name
  }
}

provider "aws" {
  region = "us-east-1"

  # profile = "default" // uncomment this if you have multiple profiles
}
