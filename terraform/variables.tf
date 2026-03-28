variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "threat-composer"
}

variable "environment" {
  description = "Environment of the project"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_az1_cidr" {
  description = "CIDR block for public subnet in AZ1"
  type        = string
}

variable "public_subnet_az2_cidr" {
  description = "CIDR block for public subnet in AZ2"
  type        = string
}

variable "private_subnet_app_az1_cidr" {
  description = "CIDR block for private app subnet in AZ1"
  type        = string
}

variable "private_subnet_app_az2_cidr" {
  description = "CIDR block for private app subnet in AZ2"
  type        = string
}

variable "load_balancer_type" {
  description = "Type of load balancer"
  type        = string
  default     = "application"
}


variable "target_type" {
  description = "Type of target"
  type        = string
  default     = "instance"
}


variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "zone_id" {
  description = "Zone ID"
  type        = string
}

variable "record_name" {
  description = "Record name"
  type        = string
}

variable "operator_email" {
  description = "Operator email"
  type        = string
}

# ECS Variables


variable "ecs_task_definition_name" {
  description = "Name of the ECS task definition"
  type        = string
}

variable "ecs_task_definition_image" {
  description = "Image of the ECS task definition"
  type        = string
} 

variable "image_tag" {
  description = "Image tag of the Docker image"
  type        = string
}
