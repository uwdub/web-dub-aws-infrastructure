output "alb" {
  value = {
    "arn"      = aws_lb.alb.arn
    "dns_name" = aws_lb.alb.dns_name
    "zone_id"  = aws_lb.alb.zone_id
  }
}

output "alb_listener" {
  value = {
    "arn" = aws_lb_listener.listener_https.arn
  }
}
