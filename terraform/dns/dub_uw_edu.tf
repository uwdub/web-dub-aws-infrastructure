resource "aws_route53_zone" "dub_uw_edu" {
  name = "dub.uw.edu"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "dub_uw_edu_alb_alias" {
  zone_id = aws_route53_zone.dub_uw_edu.zone_id
  name    = "dub.uw.edu."
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id

    evaluate_target_health = true
  }
}

resource "aws_route53_record" "dub_uw_edu_ssl_validation" {
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
  name    = "dub.uw.edu."
  type    = "MX"

  records = [
    "5 dubber.cs.washington.edu."
  ]

  ttl = "86400"
}

resource "aws_route53_record" "dub_uw_edu_spf_dubber" {
  zone_id = aws_route53_zone.dub_uw_edu.zone_id
  name    = "dub.uw.edu."
  type    = "TXT"

  records = [
    "v=spf1 include:spf.cs.uw.edu ~all"
  ]

  ttl = "600"
}

resource "aws_route53_record" "dub_uw_edu_dkim_dubber" {
  zone_id = aws_route53_zone.dub_uw_edu.zone_id
  name    = "20240412._domainkey.dub.uw.edu."
  type    = "TXT"

  records = [
    "v=DKIM1; h=sha256; k=rsa;\" \"p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAjmMgyU1YuJhTcwWbAJCP0SfDYe9nEdd3QL2XEFFmn0OqHhvjPPpUjbVxwE4/qPm69YpJft8Vxfc46sadFU6EpunxzJBFB7OsXiYx9H8mFrZmYyc8vtcRetEKWkCj7R18lTfbm7kRbZE10KLGOFYOBUOXnN3CA4fHunetvsacvU4XnxZisd1RnwFJOO4+g34BZDWSAltk/Ze0ja\" \"kkx3XAsHr+i0VN7CtPg6adgY06Q3M8prVsYW2WcvqUOubL5tadJ07SaI8XYrlTy+XgkqU5vqLHd7DU08swV96uYFD2MOpgtw5BW79k/rslAwiqSnFCllObbFYW6eW40GAYSq9sUwIDAQAB"
  ]

  ttl = "600"
}
