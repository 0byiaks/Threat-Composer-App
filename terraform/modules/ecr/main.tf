# ECR Repository
resource "aws_ecr_repository" "ecr_repo" {
  name = var.project_name  

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.environment}-${var.project_name}-ecr"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ECR Repository Policy - Allow ECS tasks to pull images
resource "aws_ecr_repository_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr_repo.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSTaskExecutionRole"
        Effect = "Allow"
        Principal = {
          AWS = "*"  # Allows any AWS principal (ECR execution role will use this)
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}