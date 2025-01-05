resource "aws_sns_topic" "infra_alerts" {
  name = var.topic_name

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

  lambda_success_feedback_sample_rate = 100
  lambda_success_feedback_role_arn = aws_iam_role.sns_delivery_status.arn
  lambda_failure_feedback_role_arn = aws_iam_role.sns_delivery_status.arn
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

output "sns_topic_arn" {
  value = aws_sns_topic.infra_alerts.arn
}

output "sns_publish_policy_arn" {
  value = aws_iam_policy.sns_publish.arn
}
