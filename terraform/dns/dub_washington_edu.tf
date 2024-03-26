resource "aws_route53_zone" "dub_washington_edu" {
  name = "dub.washington.edu"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "dub_washington_edu_alb_alias" {
  zone_id = aws_route53_zone.dub_washington_edu.zone_id
  name    = "dub.washington.edu"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id

    evaluate_target_health = false
  }
}

resource "aws_route53_record" "dub_washington_edu_validation" {
  zone_id = aws_route53_zone.dub_washington_edu.zone_id
  name    = "_a210a9a20344038976007c7f51423d10.dub.washington.edu."
  type    = "CNAME"

  records = [
    "_bb99f28ee192a932b2e6f252deb0ba2b.mhbtsbpdnt.acm-validations.aws."
  ]

  ttl = "60"
}

resource "aws_route53_record" "dub_washington_edu_mx_dubber" {
  zone_id = aws_route53_zone.dub_washington_edu.zone_id
  name    = "dub.washington.edu"
  type    = "MX"

  records = [
    "5 dubber.cs.washington.edu."
  ]

  ttl = "60"
}
