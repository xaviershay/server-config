provider "aws" {
  region = "ap-southeast-4" # Melbourne
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
