# Data source to read outputs from the DNS terraform state
data "terraform_remote_state" "dns" {
  backend = "s3"
  
  config = {
    bucket         = "xaviershay-terraform-state"
    key            = "dns.tfstate"
    region         = "ap-southeast-4"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
