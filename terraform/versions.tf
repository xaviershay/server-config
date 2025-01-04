terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "xaviershay-terraform-state"
    key            = "terraform.tfstate"
    region         = "ap-southeast-4"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }

  # It's recommended to specify which versions of Terraform this code is compatible with
  required_version = ">= 1.0"
}

