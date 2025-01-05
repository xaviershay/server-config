locals {
  backup_group_name = "backups"
}

module "terraform_state" {
  source = "./modules/terraform_state"

  bucket_name = "xaviershay-terraform-state"
}

module "infra_alerts" {
  source = "./modules/infra_alerts"

  topic_name = "infra-alerts"
  phone_number = var.phone_number
}


# Create IAM user
resource "aws_iam_user" "styx" {
  name = "styx"
  tags = {
    Description = "User for styx server"
  }
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "styx_sns" {
  user       = aws_iam_user.styx.name
  policy_arn = module.infra_alerts.sns_publish_policy_arn
}

# Add user to group
resource "aws_iam_group_membership" "backups_group_membership" {
  name  = "backups-group-membership"
  users = [aws_iam_user.styx.name]
  group = local.backup_group_name
}

# Create access key for the user
resource "aws_iam_access_key" "styx" {
  user = aws_iam_user.styx.name
}

# Output the access key details
output "styx_access_key_id" {
  value = aws_iam_access_key.styx.id
}

output "styx_secret_access_key" {
  value     = aws_iam_access_key.styx.secret
  sensitive = true
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Output the SNS topic ARN, for use in scripts
output "infra_alerts_sns_topic_arn" {
  description = "ARN of the created SNS topic"
  value       = module.infra_alerts.sns_topic_arn
}

module "backup_bucket" {
   source = "./modules/backup_bucket"

   bucket_name = "xaviershay-backups"
   group_name = local.backup_group_name
 }

moved {
  from = aws_s3_bucket.backup
  to = module.backup_bucket.aws_s3_bucket.backup
}

moved {
  from = aws_iam_group.backups
  to = module.backup_bucket.aws_iam_group.backups
}

moved {
  from = aws_s3_bucket.terraform_state
  to = module.terraform_state.aws_s3_bucket.terraform_state
}

moved {
  from = aws_dynamodb_table.terraform_locks
  to = module.terraform_state.aws_dynamodb_table.terraform_locks
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.terraform_state
  to = module.terraform_state.aws_s3_bucket_server_side_encryption_configuration.terraform_state
}

moved {
  from = aws_s3_bucket_versioning.terraform_state
  to = module.terraform_state.aws_s3_bucket_versioning.terraform_state
}
