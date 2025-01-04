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

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-4"  # Change this to your desired region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "xaviershay-terraform-state"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
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

resource "aws_s3_bucket" "backup" {
  bucket = "xaviershay-backups"
  
  # Force destroy is set to false for safety - bucket cannot be destroyed with content
  force_destroy = false
}

# Enable versioning to protect against accidental deletions
resource "aws_s3_bucket_versioning" "backup" {
  bucket = aws_s3_bucket.backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "backup" {
  bucket = aws_s3_bucket.backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configure lifecycle rules for cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    id     = "transition_to_ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Optional: Move older backups to Glacier for further cost savings
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # Optional: Delete old versions after 1 year
    expiration {
      days = 365
    }
  }
}

# Create IAM group
resource "aws_iam_group" "backups" {
  name = "backups"
}

# Attach policy to group
resource "aws_iam_group_policy_attachment" "backups_policy" {
  group      = aws_iam_group.backups.name
  policy_arn = aws_iam_policy.backup_policy.arn
}

# Add user to group
resource "aws_iam_group_membership" "backups_group_membership" {
  name  = "backups-group-membership"
  users = [aws_iam_user.styx.name]
  group = aws_iam_group.backups.name
}

# Create IAM policy allowing access to the backup bucket
resource "aws_iam_policy" "backup_policy" {
  name        = "backup-policy"
  description = "Allow access to backup bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowBackupUserAccess"
        Effect    = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.backup.arn,
          "${aws_s3_bucket.backup.arn}/*"
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

variable "phone_number" {
  description = "Phone number to receive SMS notifications"
  type        = string
  # Format: +1234567890
}
