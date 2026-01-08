# Home Assistant backup infrastructure

locals {
  homeassistant_backup_group_name = "homeassistant-backups"
}

# Create IAM user
resource "aws_iam_user" "homeassistant" {
  name = "homeassistant"
  tags = {
    Description = "User for Home Assistant backups"
  }
}

# Create dedicated backup bucket for Home Assistant
module "homeassistant_backup_bucket" {
  source = "./modules/backup_bucket"

  bucket_name = "xaviershay-homeassistant-backups"
  group_name  = local.homeassistant_backup_group_name
}

# Add user to Home Assistant backups group
resource "aws_iam_group_membership" "homeassistant_backups_group_membership" {
  name  = "homeassistant-backups-group-membership"
  users = [aws_iam_user.homeassistant.name]
  group = local.homeassistant_backup_group_name
}

# Create access key for the user
resource "aws_iam_access_key" "homeassistant" {
  user = aws_iam_user.homeassistant.name
}

# Output the access key details
output "homeassistant_access_key_id" {
  value = aws_iam_access_key.homeassistant.id
}

output "homeassistant_secret_access_key" {
  value     = aws_iam_access_key.homeassistant.secret
  sensitive = true
}

output "homeassistant_bucket_name" {
  value = local.homeassistant_backup_group_name
}
