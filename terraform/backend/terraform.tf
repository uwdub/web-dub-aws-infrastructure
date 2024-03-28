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
 * AWS configuration is provided by environment in surrounding task.
 */
provider "aws" {
}
