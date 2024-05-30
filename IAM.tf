terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_iam_user" "ahmed" {
  name = "ahmed"
}

resource "aws_iam_user_policy_attachment" "ahmed_ec2_admin" {
  user       = aws_iam_user.ahmed.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_user" "Mahmoud" {
  name = "Mahmoud"
}

data "aws_iam_policy_document" "s3_put_get_restricted" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]
    resources = ["arn:aws:s3:::*/*"]
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = ["203.0.113.0/24"] 
    }
  }
}

resource "aws_iam_user_policy" "Mahmoud_s3_policy" {
  name   = "Mahmoud_s3_policy"
  user   = aws_iam_user.Mahmoud.name
  policy = data.aws_iam_policy_document.s3_put_get_restricted.json
}

# Create IAM User
resource "aws_iam_user" "Mostafa" {
  name = "Mostafa"
}

# Create IAM Policy Document for S3 Access
data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::testasdawf4115154/*"]
  }
}

# Create IAM Policy for S3 Access
resource "aws_iam_policy" "s3_access_policy" {
  name   = "s3-access-policy"
  policy = data.aws_iam_policy_document.s3_access_policy.json
}

# Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.s3-role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Create IAM Role
resource "aws_iam_role" "s3-role" {
  name               = "s3-access-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "AWS": aws_iam_user.Mostafa.arn
      },
      "Action": "sts:AssumeRole"
    }]
  })
}

# Attach IAM Role to IAM User
resource "aws_iam_user_policy_attachment" "mostafa_role_attachment" {
  user       = aws_iam_user.Mostafa.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}
