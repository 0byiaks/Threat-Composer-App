
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
  description = "CIDR block for private subnet in AZ1 for application"
  type        = string
}

variable "private_subnet_app_az2_cidr" {
  description = "CIDR block for private subnet in AZ2 for application"
  type        = string
}


variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
