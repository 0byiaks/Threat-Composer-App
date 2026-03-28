resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.environment}-${var.project_name}-ecs-cluster"

  tags = {
    Name        = "${var.environment}-${var.project_name}-ecs-cluster"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.environment}-${var.project_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.environment}-${var.project_name}-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.environment}-${var.project_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-${var.project_name}-ecs-execution-role"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = "${var.environment}-${var.project_name}-ecs-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "256"
  memory = "512"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name = "${var.environment}-${var.project_name}"
      image = "${var.ecr_repository_url}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort = 80
          protocol = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "/ecs/${var.environment}-${var.project_name}"
          awslogs-region = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# ECS service
resource "aws_ecs_service" "ecs_service" {
  name = "${var.environment}-${var.project_name}-ecs-service"
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count = 1
  launch_type = "FARGATE"
  network_configuration {
    subnets = var.private_app_subnet_ids
    security_groups = [var.app_server_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name = "${var.environment}-${var.project_name}"
    container_port = 80
  }

  depends_on = [var.alb_target_group_arn]

  tags = {
    Name = "${var.environment}-${var.project_name}-ecs-service"
  }
}