# VPC Module - Referenced from local repository
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = var.vpc_cidr
  public_subnet_az1_cidr = var.public_subnet_az1_cidr
  public_subnet_az2_cidr = var.public_subnet_az2_cidr
  private_subnet_app_az1_cidr = var.private_subnet_app_az1_cidr
  private_subnet_app_az2_cidr = var.private_subnet_app_az2_cidr
  project_name = var.project_name
  environment = var.environment
  
}

# ACM Module
module "acm" {
  source = "git::ssh://git@github.com/0byiaks/terraform-aws-modules.git//modules/acm"

  environment = var.environment
  project_name = var.project_name
  domain_name = var.domain_name
}


# ALB Module - Referenced from local repository
module "alb" {
  source = "./modules/alb"

  project_name = var.project_name
  environment = var.environment
  load_balancer_type = var.load_balancer_type
  security_groups = [module.vpc.alb_security_group_id]
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn = module.acm.acm_certificate_arn
  target_type = var.target_type
  vpc_id = module.vpc.vpc_id
}

# Route 53 Module
module "route53" {
  source = "git::ssh://git@github.com/0byiaks/terraform-aws-modules.git//modules/route53"

  environment = var.environment
  project_name = var.project_name
  zone_id = var.zone_id
  record_name = var.record_name
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id = module.alb.alb_zone_id
  operator_email = var.operator_email
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment = var.environment
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name
  environment = var.environment
  aws_region = var.aws_region
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  app_server_security_group_id = module.vpc.app_server_security_group_id
  alb_target_group_arn = module.alb.alb_target_group_arn
  ecr_repository_url = module.ecr.ecr_repository_url
  image_tag = var.image_tag
}