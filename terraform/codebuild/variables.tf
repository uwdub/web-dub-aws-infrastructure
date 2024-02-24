/*
 * Name of CodeBuild project.
 */
variable "name" {
  type = string
}

/*
 * Path to source archive to upload for CodeBuild.
 */
variable "source_archive" {
  type = string
}
