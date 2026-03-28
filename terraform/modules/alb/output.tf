output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_alb.alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_alb.alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = aws_alb.alb.zone_id
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_alb_target_group.alb_target_group.arn
}