output "alb" {
  value = {
    "arn"      = aws_alb.alb.arn
    "dns_name" = aws_alb.alb.dns_name
  }
}

output "alb_listener" {
  value = {
    "arn" = aws_alb_listener.listener_http.arn
  }
}
