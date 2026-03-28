# AWS Configuration
aws_region = "us-east-1"
project_name = "threat-composer-app"
environment = "dev"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

# Public Subnets (one per AZ)
public_subnet_az1_cidr = "10.0.0.0/24"
public_subnet_az2_cidr = "10.0.1.0/24"

# Private App Subnets (one per AZ)
private_subnet_app_az1_cidr = "10.0.2.0/24"
private_subnet_app_az2_cidr = "10.0.3.0/24"

# Load Balancer Configuration
load_balancer_type = "application"
target_type = "ip"

# ACM Configuration
domain_name = "titotest.co.uk"
zone_id = "Z03698368RPB0I5RZFI7"
record_name = "www"
operator_email = "austinbale667@gmail.com"

# ECS Configuration
ecs_task_definition_name = "threat-composer-app"
ecs_task_definition_image = "threat-composer-app"
image_tag = "latest"

