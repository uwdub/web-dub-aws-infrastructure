/*
 * Bucket for backend state.
 */
resource "aws_s3_bucket" "terraform_state_codebuild" {
  bucket = "web-dub-aws-infrastructure-state-codebuild"

  force_destroy = true
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_codebuild" {
    bucket = aws_s3_bucket.terraform_state_codebuild.id

    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_kms_key" "terraform_state_codebuild" {
  description             = "Key for bucket web-dub-aws-infrastructure-state-codebuild"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_codebuild" {
  bucket = aws_s3_bucket.terraform_state_codebuild.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state_codebuild.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
