terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "xaviershay-terraform-state"
    key            = "dns.tfstate"
    region         = "ap-southeast-4"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }

  required_version = ">= 1.0"
}
