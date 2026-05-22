resource "aws_s3_bucket" "practice" {
  bucket = "rain-terraform-s3-basic-20260520"

  tags = {
    Name        = "rain-terraform-s3-basic-20260520"
    Environment = "practice"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "practice" {
  bucket = aws_s3_bucket.practice.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "practice" {
  bucket = aws_s3_bucket.practice.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "practice" {
  bucket = aws_s3_bucket.practice.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
