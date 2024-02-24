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

  required_version = "1.7.4"
}

/*
 * Configure AWS profile.
 */
provider "aws" {
  profile = "probe"
}

/*
 * Table for backend locking.
 */
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "web-dub-aws-infrastructure-state-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
