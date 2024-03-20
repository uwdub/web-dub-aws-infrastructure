resource "aws_ecs_cluster" "cluster" {
  name            = "${var.name}-cluster"
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
      image        = var.repository_url
      portMappings = [
        {
          containerPort: 80
        }
      ]
    }
  ])
}
