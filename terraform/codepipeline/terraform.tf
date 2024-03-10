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
    bucket = "web-dub-backend-tfstate-codepipeline"
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
 * Key for artifact store bucket encryption.
 */
resource "aws_kms_key" "key_bucket_artifact_store" {
  description             = "Key for artifact store bucket of ${var.name}"
  deletion_window_in_days = 10
}

/*
 * Artifact store bucket.
 */
resource "aws_s3_bucket" "bucket_artifact_store" {
  bucket = "artifact-store-${var.name}"
}

/*
 * Apply artifact store bucket encryption.
 */
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_artifact_store" {
  bucket = aws_s3_bucket.bucket_artifact_store.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.key_bucket_artifact_store.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# resource "aws_s3_bucket_versioning" "backend_buckets" {
#   for_each = aws_s3_bucket.backend_buckets
#
#   bucket = each.value.id
#
#   versioning_configuration {
#     status = "Enabled"
#   }
# }


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
        "codepipeline.amazonaws.com",
      ]
    }
  }
}

/*
 * Policy document for the CodePipeline role.
 */
data "aws_iam_policy_document" "policy_document_codepipeline" {
  statement {
    effect    = "Allow"

    actions   = ["codestar-connections:UseConnection"]

    resources = [aws_codestarconnections_connection.github.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketVersioning",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = [
      aws_s3_bucket.bucket_artifact_store.arn,
      "${aws_s3_bucket.bucket_artifact_store.arn}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = [
      aws_kms_key.key_bucket_artifact_store.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = [
      var.codebuild_arn,
    ]
  }
}

/*
 * Policy for the CodePipeline role.
 */
resource "aws_iam_policy" "policy_codepipeline" {
  policy = data.aws_iam_policy_document.policy_document_codepipeline.json
}

/*
 * Role that defines access policies for the pipeline.
 */
resource "aws_iam_role" "role_codepipeline" {
  name = "role-codepipeline-${var.name}"

  assume_role_policy = data.aws_iam_policy_document.policy_document_assume.json
  managed_policy_arns = [
    aws_iam_policy.policy_codepipeline.arn,
  ]
}

/*
 * CodePipeline.
 */
resource "aws_codepipeline" "codepipeline" {
  name = var.name

  pipeline_type = "V2"
  execution_mode = "QUEUED"

  role_arn = aws_iam_role.role_codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.bucket_artifact_store.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.key_bucket_artifact_store.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.git_repository_id
        BranchName       = var.git_repository_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = var.codebuild_name
      }
    }
  }
}
