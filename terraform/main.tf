locals {
  backup_group_name = "backups"
}

module "terraform_state" {
  source = "./modules/terraform_state"

  bucket_name = "xaviershay-terraform-state"
}

# Create the SNS topic
resource "aws_sns_topic" "infra_alerts" {
  name = "infra-alerts"

  # Enable content-based deduplication if needed
  # fifo_topic = true
  # content_based_deduplication = true

  # Enable server-side encryption
  kms_master_key_id = "alias/aws/sns"

  # Set a delivery policy
  delivery_policy = jsonencode({
    http = {
      defaultHealthyRetryPolicy = {
        minDelayTarget     = 20
        maxDelayTarget     = 20
        numRetries         = 3
        numMaxDelayRetries = 0
        numNoDelayRetries  = 0
        numMinDelayRetries = 0
        backoffFunction    = "linear"
      }
      disableSubscriptionOverrides = false
    }
  })

  tags = {
    Environment = "production"
    Purpose     = "Infrastructure alerts"
    ManagedBy   = "terraform"
  }
}

resource "aws_sns_topic" "notifications" {
  name = "my-sms-notifications"

  # Enable CloudWatch logging
  lambda_success_feedback_sample_rate = 100
  lambda_success_feedback_role_arn    = aws_iam_role.sns_delivery_status.arn
  lambda_failure_feedback_role_arn    = aws_iam_role.sns_delivery_status.arn
}

# Optional: Create an SNS topic policy
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.infra_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "infra-alerts-topic-policy"
    Statement = [
      {
        Sid    = "AllowIAMUserPublish"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.infra_alerts.arn
      },
      {
        Sid    = "AllowAWSServices"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"  # Add other AWS services as needed
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.infra_alerts.arn
      }
    ]
  })
}

# Create SMS subscription
resource "aws_sns_topic_subscription" "sms" {
  topic_arn = aws_sns_topic.infra_alerts.arn
  protocol  = "sms"
  endpoint  = var.phone_number
}

resource "aws_sns_sms_preferences" "update_settings" {
  default_sender_id    = "Styx"    # Up to 11 alphanumeric characters
  default_sms_type     = "Transactional"  # or "Promotional"
  delivery_status_iam_role_arn = aws_iam_role.sns_delivery_status.arn
  # usage_report_s3_bucket = "my-sns-delivery-logs"  # Optional
}

resource "aws_iam_role" "sns_delivery_status" {
  name = "sns-delivery-status"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM user
resource "aws_iam_user" "styx" {
  name = "styx"
  tags = {
    Description = "User for styx server"
  }
}

# Create IAM policy allowing publish to specific SNS topic
resource "aws_iam_policy" "sns_publish" {
  name        = "sns-publish-infra-alerts"
  description = "Allow publishing to infrastructure alerts SNS topic"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [
          aws_sns_topic.infra_alerts.arn
        ]
      }
    ]
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "styx_sns" {
  user       = aws_iam_user.styx.name
  policy_arn = aws_iam_policy.sns_publish.arn
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

# Output the SNS topic ARN
output "infra_alerts_sns_topic_arn" {
  description = "ARN of the created SNS topic"
  value       = aws_sns_topic.infra_alerts.arn
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
