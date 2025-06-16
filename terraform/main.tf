provider "aws" {
  region = var.region
}

resource "aws_ecr_repository" "hoops" {
  name = "hoops"
}

resource "aws_ecs_cluster" "hoops" {
  name = "hoops-cluster"
}

resource "aws_iam_role" "task_exec_role" {
  name = "hoops-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "task_exec_policy" {
  role       = aws_iam_role.task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "hoops" {
  name        = "hoops-sg"
  description = "Allow inbound HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "hoops" {
  family                   = "hoops-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.task_exec_role.arn

  container_definitions = jsonencode([
    {
      name  = "hoops"
      image = var.container_image
      portMappings = [{
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }]
    }
  ])
}

resource "aws_ecs_service" "hoops" {
  name            = "hoops-service"
  cluster         = aws_ecs_cluster.hoops.id
  task_definition = aws_ecs_task_definition.hoops.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.hoops.id]
    assign_public_ip = true
  }
}

output "service_name" {
  value = aws_ecs_service.hoops.name
}

output "cluster_name" {
  value = aws_ecs_cluster.hoops.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.hoops.repository_url
}
