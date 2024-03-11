/*
 * S3 upload of CodeBuild source.
 */
resource "aws_s3_object"  "object_codebuild_source" {
  bucket = aws_s3_bucket.bucket_codebuild_source.id
  key = "${var.name_codebuild}.zip"
  source = var.source_archive_codebuild

  # etag triggers upload when file changes
  etag = filemd5(var.source_archive_codebuild)
}

/*
 * Policy document for assuming the CodeBuild role.
 */
data "aws_iam_policy_document" "policy_document_codebuild_assume" {
  statement {
    effect = "Allow"

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
    effect = "Allow"

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
    effect = "Allow"

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
    effect = "Allow"

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

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = [
      "*",
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
 * Role for CodeBuild.
 */
resource "aws_iam_role" "role_codebuild" {
  name = "role_codebuild_${var.name_codebuild}"

  assume_role_policy = data.aws_iam_policy_document.policy_document_codebuild_assume.json
  managed_policy_arns = [
    aws_iam_policy.policy_codebuild.arn,
  ]
}

/*
 * Group for logs.
 */
resource "aws_cloudwatch_log_group" "logs_codebuild" {
  name = "/aws/codebuild/${var.name_codebuild}"
}

/*
 * Codebuild project.
 */
resource "aws_codebuild_project" "codebuild_project" {
  name = var.name_codebuild

  service_role = aws_iam_role.role_codebuild.arn

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
    location = "${aws_s3_object.object_codebuild_source.bucket}/${aws_s3_object.object_codebuild_source.key}"
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.logs_codebuild.name
    }
  }
}