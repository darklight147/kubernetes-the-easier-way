terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.63.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"

  # profile = "default" // uncomment this if you have multiple profiles
}
