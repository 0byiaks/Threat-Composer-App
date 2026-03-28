variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "load_balancer_type" {
  description = "Type of load balancer"
  type        = string
}

variable "security_groups" {
  description = "Security groups for the load balancer"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the load balancer"
  type        = list(string)    
}

variable "certificate_arn" {
  description = "ARN of the certificate"
  type        = string
}

variable "target_type" {
  description = "Type of target"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}