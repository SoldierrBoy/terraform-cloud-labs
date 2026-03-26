provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "storage" {
  bucket = "lab7-storage-${random_id.suffix.hex}"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.storage.id

  rule {
    id     = "move-to-cool"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_object" "folder" {
  bucket = aws_s3_bucket.storage.id
  key    = "data/"
}

resource "aws_s3_object" "file" {
  bucket = aws_s3_bucket.storage.id
  key    = "data/test.txt"
  content = "Hello from Lab7"
}


output "bucket_name" {
  value = aws_s3_bucket.storage.bucket
}