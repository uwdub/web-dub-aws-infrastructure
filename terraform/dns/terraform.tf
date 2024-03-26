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
    bucket = "web-dub-backend-tfstate-dns"
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
