resource "aws_route53_zone" "dub_uw_edu" {
  name = "dub.uw.edu"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "dub_uw_edu_alb_alias" {
  zone_id = aws_route53_zone.dub_uw_edu.zone_id
  name    = "dub.uw.edu"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id

    evaluate_target_health = true
  }
}

resource "aws_route53_record" "dub_uw_edu_validation" {
  zone_id = aws_route53_zone.dub_uw_edu.zone_id
  name    = "_5cf2dee12e9eb272e7934510fa27292d.dub.uw.edu."
  type    = "CNAME"

  records = [
    "_adc6fdd41c7e50385f2129886797313f.mhbtsbpdnt.acm-validations.aws."
  ]

  ttl = "300"
}

resource "aws_route53_record" "dub_uw_edu_mx_dubber" {
  zone_id = aws_route53_zone.dub_uw_edu.zone_id
  name    = "dub.uw.edu"
  type    = "MX"

  records = [
    "5 dubber.cs.washington.edu."
  ]

  ttl = "86400"
}
