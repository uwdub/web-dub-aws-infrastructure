resource "aws_acm_certificate" "dub_washington_edu" {
  domain_name       = "dub.washington.edu"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.dub.washington.edu",
    "dub.uw.edu",
    "www.dub.uw.edu",
  ]
}

output "validations_dub_washington_edu" {
  value = aws_acm_certificate.dub_washington_edu.domain_validation_options
}
