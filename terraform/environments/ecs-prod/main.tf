locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name

  vpc_cidr                    = "10.0.0.0/16"
  public_subnet_az1_cidr      = "10.0.1.0/24"
  public_subnet_az2_cidr      = "10.0.2.0/24"
  private_app_subnet_az1_cidr = "10.0.3.0/24"
  private_app_subnet_az2_cidr = "10.0.4.0/24"
  private_db_subnet_az1_cidr  = "10.0.5.0/24"
  private_db_subnet_az2_cidr  = "10.0.6.0/24"
}

module "security_groups" {
  source = "../../modules/security-groups"

  name_prefix             = local.name_prefix
  vpc_id                  = module.vpc.vpc_id
  frontend_container_port = var.frontend_container_port
  backend_container_port  = var.backend_container_port
  common_tags             = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  project_name          = var.project_name
  environment           = var.environment
  rds_security_group_id = module.security_groups.rds_security_group_id
  subnet_ids = [
    module.vpc.private_app_subnet_az1_id,
    module.vpc.private_app_subnet_az2_id
  ]

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

module "secrets" {
  source = "../../modules/secrets"

  project_name = var.project_name
  environment  = var.environment
  db_username  = var.db_username
  db_password  = var.db_password
  db_address   = module.rds.db_address
  db_name      = var.db_name
}


# ------------------------------------------------------------
# Application Load Balancer
# ------------------------------------------------------------

module "alb" {
  source = "../../modules/alb"

  name_prefix             = local.name_prefix
  vpc_id                  = module.vpc.vpc_id
  alb_security_group_id   = module.security_groups.alb_security_group_id
  frontend_container_port = var.frontend_container_port
  backend_container_port  = var.backend_container_port
  public_subnet_ids = [
    module.vpc.public_subnet_az1_id,
    module.vpc.public_subnet_az2_id
  ]
  common_tags = local.common_tags
}


module "iam" {
  source = "../../modules/iam"

  name_prefix             = local.name_prefix
  database_url_secret_arn = module.secrets.database_url_secret_arn
  common_tags             = local.common_tags
}

# ------------------------------------------------------------
# CloudWatch Log Groups
# ------------------------------------------------------------

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project_name                     = var.project_name
  name_prefix                      = local.name_prefix
  environment                      = var.environment
  common_tags                      = local.common_tags
  alert_email                      = var.alert_email
  alb_arn_suffix                   = module.alb.alb_arn_suffix
  frontend_target_group_arn_suffix = module.alb.frontend_target_group_arn_suffix
  backend_target_group_arn_suffix  = module.alb.backend_target_group_arn_suffix
  rds_instance_identifier          = module.rds.db_instance_identifier
  ecs_cluster_name                 = "${local.name_prefix}-cluster"
  frontend_service_name            = "${local.name_prefix}-frontend-service"
  backend_service_name             = "${local.name_prefix}-backend-service"
}

# ------------------------------------------------------------
# ECS
# ------------------------------------------------------------

module "ecs" {
  source = "../../modules/ecs"

  name_prefix                 = local.name_prefix
  aws_region                  = var.aws_region
  common_tags                 = local.common_tags
  frontend_image_uri          = var.frontend_image_uri
  backend_image_uri           = var.backend_image_uri
  frontend_container_port     = var.frontend_container_port
  backend_container_port      = var.backend_container_port
  frontend_cpu                = var.frontend_cpu
  frontend_memory             = var.frontend_memory
  backend_cpu                 = var.backend_cpu
  backend_memory              = var.backend_memory
  frontend_desired_count      = var.frontend_desired_count
  backend_desired_count       = var.backend_desired_count
  min_task_count              = var.min_task_count
  max_task_count              = var.max_task_count
  cpu_target_value            = var.cpu_target_value
  ecs_tasks_security_group_id = module.security_groups.ecs_tasks_security_group_id
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  frontend_log_group_name     = module.cloudwatch.frontend_log_group_name
  backend_log_group_name      = module.cloudwatch.backend_log_group_name
  database_url_secret_arn     = module.secrets.database_url_secret_arn
  frontend_target_group_arn   = module.alb.frontend_target_group_arn
  backend_target_group_arn    = module.alb.backend_target_group_arn
  private_app_subnet_ids = [
    module.vpc.private_app_subnet_az1_id,
    module.vpc.private_app_subnet_az2_id
  ]

  depends_on = [
    module.alb,
    aws_lb_listener_rule.https_api
  ]
}
