terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # It's recommended to specify which versions of Terraform this code is compatible with
  required_version = ">= 1.0"
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-4"  # Change this to your desired region
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
