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

# resource "aws_lb_listener_rule" "api_to_backend" {
#   listener_arn = module.alb.http_listener_arn
#   priority     = 10

#   action {
#     type             = "forward"
#     target_group_arn = module.alb.backend_target_group_arn
#   }

#   condition {
#     path_pattern {
#       values = ["/api/*"]
#     }
#   }
# }

# ------------------------------------------------------------
# ECS Cluster
# ------------------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cluster"
  })
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

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags
}

# ------------------------------------------------------------
# ECS Task Definitions
# ------------------------------------------------------------

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${local.name_prefix}-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.frontend_cpu
  memory                   = var.frontend_memory
  execution_role_arn       = module.iam.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = var.frontend_image_uri
      essential = true

      portMappings = [
        {
          containerPort = var.frontend_container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = module.cloudwatch.frontend_log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "frontend"
        }
      }
    }
  ])

  tags = local.common_tags
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${local.name_prefix}-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  execution_role_arn       = module.iam.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = var.backend_image_uri
      essential = true

      portMappings = [
        {
          containerPort = var.backend_container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "PORT"
          value = tostring(var.backend_container_port)
        }
      ]

      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = module.secrets.database_url_secret_arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = module.cloudwatch.backend_log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "backend"
        }
      }
    }
  ])

  tags = local.common_tags
}

# ------------------------------------------------------------
# ECS Services
# ------------------------------------------------------------

resource "aws_ecs_service" "frontend" {
  name            = "${local.name_prefix}-frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.frontend_desired_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 60

  network_configuration {
    subnets = [
      module.vpc.private_app_subnet_az1_id,
      module.vpc.private_app_subnet_az2_id
    ]
    security_groups  = [module.security_groups.ecs_tasks_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.frontend_target_group_arn
    container_name   = "frontend"
    container_port   = var.frontend_container_port
  }

  depends_on = [
    module.alb
  ]

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = local.common_tags
}

resource "aws_ecs_service" "backend" {
  name            = "${local.name_prefix}-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.backend_desired_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = 60

  network_configuration {
    subnets = [
      module.vpc.private_app_subnet_az1_id,
      module.vpc.private_app_subnet_az2_id
    ]
    security_groups  = [module.security_groups.ecs_tasks_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.backend_target_group_arn
    container_name   = "backend"
    container_port   = var.backend_container_port
  }

  depends_on = [
    aws_lb_listener_rule.https_api
  ]

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = local.common_tags
}

# ------------------------------------------------------------
# ECS Service Autoscaling
# ------------------------------------------------------------

resource "aws_appautoscaling_target" "frontend" {
  max_capacity       = var.max_task_count
  min_capacity       = var.min_task_count
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.frontend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "frontend_cpu" {
  name               = "${local.name_prefix}-frontend-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.frontend.resource_id
  scalable_dimension = aws_appautoscaling_target.frontend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.frontend.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.cpu_target_value

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_target" "backend" {
  max_capacity       = var.max_task_count
  min_capacity       = var.min_task_count
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "backend_cpu" {
  name               = "${local.name_prefix}-backend-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend.resource_id
  scalable_dimension = aws_appautoscaling_target.backend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.cpu_target_value

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
