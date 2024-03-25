/*
 * URL of the registry containing the repositories.
 */
output "registry_url" {
  value = split("/", aws_ecr_repository.ecr[tolist(var.repositories)[0]].repository_url)[0]
}

/*
 * URLs of the repositories.
 */
output "repositories" {
  value = tomap({
    for name, ecr in aws_ecr_repository.ecr : name => {
      "name"           = name
      "arn"            = ecr.arn
      "repository_url" = ecr.repository_url
    }
  })
}
