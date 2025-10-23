resource "aws_ecs_task_definition" "app" {
  family =     "my-service-task"
  network_mode = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([{
    name = "app-container"
    image = var.image_uri
    memory = 512
    portMappings = [{
        containerPort = 80,
        hostPort = 0,
        protocol = "tcp"
        
    }]
  }])
}

resource "aws_ecs_service" "app" {
    name          =  "my_service"
    cluster       = var.cluster_name
    task_definition = aws_ecs_task_definition.app.arn
    launch_type = "EC2"
    desired_count = 2

    load_balancer {
      target_group_arn = aws_lb_target_group.app.arn
      container_name = "app-container"
      container_port = 80
      }
    depends_on = [aws_lb_listener.app]
}

resource "aws_lb" "app" {
  name = "my-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = var.security_groups
  subnets = var.subnets_ids
}

resource "aws_lb_target_group" "app" {
  name = "my-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "instance"
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_iam_role" "task_execution" {
  name = "${var.cluster_name}-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "task_definition" {
    role = aws_iam_role.task_execution.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  
}

output "load_balancer_url" {
  value = "http://$(aws_lb.app.dns_name)"
}