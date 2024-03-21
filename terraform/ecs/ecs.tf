resource "aws_ecs_cluster" "cluster" {
  name            = "${var.name}-cluster"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.name}-task"

  execution_role_arn       = aws_iam_role.role_ecs.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                      = 256
  memory                   = 512

  container_definitions    = jsonencode([
    {
      name         = var.name
      image        = var.ecr_repository.repository_url
      portMappings = [
        {
          containerPort: 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = "${var.name}-service"

  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.cluster.id

  network_configuration {
    // Executing in a public subnet requires a public ip
    assign_public_ip = true

    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
  }

  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn

    container_name = var.name
    container_port = 80
  }
}

resource "aws_lb_target_group" "target_group" {
  name = var.name
  port = 80

  protocol    = "HTTP"
  target_type = "ip"

  vpc_id = var.vpc_id
}

resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = var.alb_listener_arn

  priority = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
