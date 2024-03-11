/*
 * CodePipeline project name.
 */
variable "name_codepipeline" {
  type = string
}

/*
 * CodePipeline project name.
 */
variable "name_codebuild" {
  type = string
}

/*
 * Path to source archive to upload for CodeBuild.
 */
variable "source_archive_codebuild" {
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
