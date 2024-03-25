resource "aws_kms_key" "backend_key" {
  description             = "Key for state buckets of ${var.name}"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "backend_buckets" {
  for_each = toset(var.states)

  bucket = join("-", [var.name, "tfstate", each.key])

  force_destroy = true
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "backend_buckets" {
  for_each = aws_s3_bucket.backend_buckets

  bucket = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend_buckets" {
  for_each = aws_s3_bucket.backend_buckets

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.backend_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
