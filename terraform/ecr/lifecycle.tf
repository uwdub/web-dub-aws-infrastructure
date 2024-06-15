/*
 * A lifecycle that preserves "latest" and then 5 previous images.
 */
data "aws_ecr_lifecycle_policy_document" "policy_document" {
  for_each = var.repositories

  rule {
    priority    = 1
    description = "Preserve latest."

    action {
      type = "expire"
    }

    selection {
      tag_status      = "tagged"
      tag_prefix_list = ["latest"]
      count_type      = "imageCountMoreThan"
      count_number    = 1
    }
  }

  rule {
    priority    = 2
    description = "Preserve 5 previous images."

    action {
      type = "expire"
    }

    selection {
      tag_status      = "any"
      count_type      = "imageCountMoreThan"
      count_number    = 5
    }
  }
}

resource "aws_ecr_lifecycle_policy" "policy" {
  for_each = var.repositories

  repository = aws_ecr_repository.ecr[each.value].name

  policy = data.aws_ecr_lifecycle_policy_document.policy_document[each.value].json
}
