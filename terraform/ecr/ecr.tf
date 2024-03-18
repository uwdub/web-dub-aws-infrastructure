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
