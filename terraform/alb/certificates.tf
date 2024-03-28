resource "aws_acm_certificate" "dub_uw_edu" {
  domain_name       = "dub.uw.edu"
  validation_method = "DNS"

  subject_alternative_names = [
    "dub.washington.edu",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

output "validations_dub_washington_edu" {
  value = aws_acm_certificate.dub_uw_edu.domain_validation_options
}
