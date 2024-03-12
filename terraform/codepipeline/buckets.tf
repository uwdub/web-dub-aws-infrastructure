/*
 * Key for project bucket encryption.
 */
resource "aws_kms_key" "key_buckets" {
  description             = "Key for buckets of ${var.name_codepipeline}"
  deletion_window_in_days = 10
}

/*
 * Bucket for CodePipeline artifact store.
 */
resource "aws_s3_bucket" "bucket_artifact_store" {
  force_destroy = true
}

/*
 * Apply bucket encryption.
 */
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_artifact_store" {
  bucket = aws_s3_bucket.bucket_artifact_store.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.key_buckets.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

/*
 * Bucket for CodeBuild source.
 */
resource "aws_s3_bucket" "bucket_codebuild_source" {
  force_destroy = true
}

/*
 * Enabling versioning, required as CodePipeline source.
 */
resource "aws_s3_bucket_versioning" "bucket_codebuild_source" {
  bucket = aws_s3_bucket.bucket_codebuild_source.id

  versioning_configuration {
    status = "Enabled"
  }
}

/*
 * Apply bucket encryption.
 */
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_codebuild_source" {
  bucket = aws_s3_bucket.bucket_codebuild_source.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.key_buckets.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
