/*
 * Policy document for assuming the defined role.
 */
data "aws_iam_policy_document" "policy_document_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}

/*
 * Policy document for the CodePipeline role.
 */
data "aws_iam_policy_document" "policy_document_ecs" {
  statement {
    effect    = "Allow"

    actions   = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
    ]

    resources = [
      "*"
    ]
  }
}

/*
 * Policy created from document.
 */
resource "aws_iam_policy" "policy_ecs" {
  policy = data.aws_iam_policy_document.policy_document_ecs.json
}

/*
 * Role that applies access policies.
 */
resource "aws_iam_role" "role_ecs" {
  name = "role-ecs-${var.name}"

  assume_role_policy = data.aws_iam_policy_document.policy_document_assume.json
  managed_policy_arns = [
    aws_iam_policy.policy_ecs.arn,
  ]
}
