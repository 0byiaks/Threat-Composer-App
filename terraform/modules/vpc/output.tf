# VPC
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}

# Public Subnets
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [aws_subnet.public_az1.id, aws_subnet.public_2.id]
}

# Private App Subnets
output "private_app_subnet_ids" {
  description = "IDs of the private application subnets"
  value       = [aws_subnet.private_app_az1.id, aws_subnet.private_app_az2.id]
}


# Security Groups
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}


# NAT Gateway
output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.nat_gateway.id
}

# Application Server Security Group
output "app_server_security_group_id" {
  description = "ID of the application server security group"
  value       = aws_security_group.app_server_sg.id
}