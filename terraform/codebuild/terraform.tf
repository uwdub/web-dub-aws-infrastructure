/*
 * Pin specific versions.
 */
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.38.0"
    }
  }

  /*
   * AWS configuration is provided by environment in surrounding task.
   */
  backend "s3" {
    bucket = "web-dub-backend-tfstate-codebuild"
    key = "state/terraform.tfstate"
    dynamodb_table = "web-dub-backend-tfstate-lock"
  }

  required_version = "1.7.4"
}

/*
 * AWS configuration is provided by environment in surrounding task.
 */
provider "aws" {
}

/*
 * S3 bucket in which to place archive of source.
 */
resource "aws_s3_bucket" "codebuild_source_bucket" {
}

/*
 * S3 upload of source.
 */
resource "aws_s3_object"  "codebuild_source_object" {
  bucket = aws_s3_bucket.codebuild_source_bucket.id
  key = "${var.name}.zip"
  source = var.source_archive

  # etag triggers upload when file changes
  etag = filemd5(var.source_archive)
}

/*
 * Policy document for assuming the defined role.
 */
data "aws_iam_policy_document" "policy_document_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com",
      ]
    }
  }
}

/*
 * Policy document for the CodeBuild role.
 */
data "aws_iam_policy_document" "policy_document_codebuild" {
  # CodeBuild policy for permissive access to logging
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*"
    ]
  }

  # CodeBuild policy for permissive access to S3
  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
    ]

    resources = [
      "*"
    ]
  }

  # CodeBuild policy for permissive access to ECR
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]

    resources = [
      "*"
    ]
  }
}

/*
 * Policy for the CodeBuild role.
 */
resource "aws_iam_policy" "policy_codebuild" {
  policy = data.aws_iam_policy_document.policy_document_codebuild.json
}

/*
 * Role that defines access policies for project.
 */
resource "aws_iam_role" "codebuild_project_role" {
  name = "codebuild_role_${var.name}"

  assume_role_policy = data.aws_iam_policy_document.policy_document_assume.json
  managed_policy_arns = [
    aws_iam_policy.policy_codebuild.arn,
  ]
}

/*
 * Group for logs.
 */
resource "aws_cloudwatch_log_group" "logs" {
  name = "/aws/codebuild/${var.name}"
}

/*
 * Codebuild project.
 */
resource "aws_codebuild_project" "codebuild_project" {
  name = var.name

  service_role = aws_iam_role.codebuild_project_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    type = "LINUX_CONTAINER"
    image = "aws/codebuild/standard:5.0"

    privileged_mode = true
  }

  source {
    type = "S3"
    location = "${aws_s3_object.codebuild_source_object.bucket}/${aws_s3_object.codebuild_source_object.key}"
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.logs.name
    }
  }
}
