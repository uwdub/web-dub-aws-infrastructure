resource "aws_alb" "alb" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"

  enable_deletion_protection = true

  subnets         = var.subnet_ids
  security_groups = var.security_group_ids
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "503"
      message_body = "Request not matched."
    }
  }
}