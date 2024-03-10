/*
 * CodePipeline project name.
 */
variable "name" {
  type = string
}

/*
 * Git repository ID.
 */
variable "git_repository_id" {
  type = string
}

/*
 * Git repository branch.
 */
variable "git_repository_branch" {
  type = string
}

/*
 * CodeBuild project ARN.
 */
variable "codebuild_arn" {
  type = string
}

/*
 * CodeBuild project name.
 */
variable "codebuild_name" {
  type = string
}
