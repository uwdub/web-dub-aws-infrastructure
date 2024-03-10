/*
 * CodeBuild ARN.
 */
output "codebuild_arn" {
  value = aws_codebuild_project.codebuild_project.arn
}

/*
 * CodeBuild name.
 */
output "codebuild_name" {
  value = aws_codebuild_project.codebuild_project.name
}
