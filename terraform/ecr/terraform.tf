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
    bucket = "web-dub-backend-tfstate-ecr"
    key = "state/terraform.tfstate"
    dynamodb_table = "web-dub-backend-tfstate-lock"
  }

  required_version = "1.7.4"
}

/*
 * The ECR.
 */
resource "aws_ecr_repository" "ecr" {
  for_each = var.names

  name = each.value

  force_delete = true
  lifecycle {
    prevent_destroy = true
  }
}