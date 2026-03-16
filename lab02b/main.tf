terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "lab_bucket" {
  bucket = "lab02b-terraform-ivan-123456"

  tags = {
    CostCenter = "000"
  }
}
resource "aws_iam_policy" "require_costcenter_tag" {
  name = "require-costcenter-tag"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = "s3:CreateBucket"
        Resource = "*"
        Condition = {
          Null = {
            "aws:RequestTag/CostCenter" = "true"
          }
        }
      }
    ]
  })
}
resource "aws_s3_bucket" "lab_bucket_auto_tag" {
  bucket = "lab02b-terraform-auto-ivan-123456"

  tags = {
    CostCenter = "000"
  }
}
resource "aws_s3_bucket_policy" "prevent_delete" {
  bucket = aws_s3_bucket.lab_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PreventBucketDeletion"
        Effect = "Deny"
        Principal = "*"
        Action = [
          "s3:DeleteBucket"
        ]
        Resource = aws_s3_bucket.lab_bucket.arn
      }
    ]
  })
}