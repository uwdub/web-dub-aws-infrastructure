resource "aws_codestarconnections_connection" "github" {
  name          = "github-uwdub"
  provider_type = "GitHub"
}
