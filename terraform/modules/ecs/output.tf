

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.ecs_service.name
}

output "ecs_service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.ecs_service.id
}