/*
 * Table for backend locking.
 */
resource "aws_dynamodb_table" "backend_tfstate_lock" {
  name           = join("-", [var.name, "tfstate-lock"])
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
