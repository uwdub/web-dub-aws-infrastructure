resource "aws_route53_zone" "dub_washington_edu" {
  name = "dub.washington.edu"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "dub_washington_edu_alb_alias" {
  zone_id = aws_route53_zone.dub_washington_edu.zone_id
  name    = "dub.washington.edu."
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id

    evaluate_target_health = true
  }
}

resource "aws_route53_record" "dub_washington_edu_ssl_validation" {
  zone_id = aws_route53_zone.dub_washington_edu.zone_id
  name    = "_a210a9a20344038976007c7f51423d10.dub.washington.edu."
  type    = "CNAME"

  records = [
    "_bb99f28ee192a932b2e6f252deb0ba2b.mhbtsbpdnt.acm-validations.aws."
  ]

  ttl = "300"
}

resource "aws_route53_record" "dub_washington_edu_mx_dubber" {
  zone_id = aws_route53_zone.dub_washington_edu.zone_id
  name    = "dub.washington.edu."
  type    = "MX"

  records = [
    "5 dubber.cs.washington.edu."
  ]

  ttl = "86400"
}

resource "aws_route53_record" "dub_washington_edu_spf_dubber" {
  zone_id = aws_route53_zone.dub_washington_edu.zone_id
  name    = "dub.washington.edu."
  type    = "TXT"

  records = [
    "v=spf1 include:spf.cs.uw.edu ~all"
  ]

  ttl = "600"
}

resource "aws_route53_record" "dub_washington_edu_dkim_dubber" {
  zone_id = aws_route53_zone.dub_washington_edu.zone_id
  name    = "20240410._domainkey.dub.washington.edu."
  type    = "TXT"

  records = [
    "v=DKIM1; h=rsa-sha256; k=rsa;\" \"p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4Upk03L89MiLDZSLwmjIMRvVbPpmjlB7R0PdRgHMLpYNIqHGCY5oayM5mYKHB3Gz9VNWVBfuQtTKe4Hd+ITzMfB/QLF8Cs32ja+urrORw2dpwAznhDG70hGIQ8m606QULLk1OcZhHsMqe5xcBCEI1E19EzP6GhOqaVHzJUClRxrsWXKJ1FKzFzjBvKN9k9grh57Hj373/RxnIs\" \"/qLlnm64EoDZJt0NkKX/1IRunQZl0BK3HrrZq3LmGzWVRT4GlZIJJ35uUjXBoAZfEUzAgLHu3n3BFpxHA066iRWQDQMeIASp934z6JJohK0D9j19CqEchWCj3/IhZ+MUcBG4Ej7QIDAQAB"
  ]

  ttl = "600"
}
