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

  vpc_cidr                    = "10.10.0.0/16"
  public_subnet_az1_cidr      = "10.10.1.0/24"
  public_subnet_az2_cidr      = "10.10.2.0/24"
  private_app_subnet_az1_cidr = "10.10.3.0/24"
  private_app_subnet_az2_cidr = "10.10.4.0/24"
  private_db_subnet_az1_cidr  = "10.10.5.0/24"
  private_db_subnet_az2_cidr  = "10.10.6.0/24"
}

module "ec2_hosting" {
  source = "../../modules/ec2-hosting"

  project_name     = var.project_name
  environment      = var.environment
  name_prefix      = local.name_prefix
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_az1_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
  instance_type    = var.instance_type
  key_name         = var.key_name
  common_tags      = local.common_tags
}
