resource "aws_s3_bucket" "backup" {
  bucket = var.bucket_name

  # Force destroy is set to false for safety - bucket cannot be destroyed with
  # content
  force_destroy = false
}

# Enable versioning to protect against accidental deletions
resource "aws_s3_bucket_versioning" "backup" {
  bucket = aws_s3_bucket.backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "backup" {
  bucket = aws_s3_bucket.backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    id     = "transition_to_ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Move older backups to Glacier for further cost savings
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # Delete old versions after 1 year
    expiration {
      days = 365
    }
  }
}

resource "aws_iam_group" "backups" {
  name = var.group_name
}

resource "aws_iam_group_policy_attachment" "backups_policy" {
  group      = aws_iam_group.backups.name
  policy_arn = aws_iam_policy.backup_policy.arn
}

resource "aws_iam_policy" "backup_policy" {
  name        = "backup-policy"
  description = "Allow put access to backup bucket"

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
