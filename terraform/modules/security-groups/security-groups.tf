resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Security group for the ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "alb-security-group"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Security group for the app tier"
  vpc_id      = var.vpc_id

  tags = {
    Name = "app-security-group"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db-security-group"
  description = "Security group for the database tier"
  vpc_id      = var.vpc_id

  tags = {
    Name = "db-security-group"
  }
}



















# # create security group for the application load balancer
# resource "aws_security_group" "alb_security_group" {
#   name        = "alb security group"
#   description = "enable http/https access on port 80/443"
#   vpc_id      = var.vpc_id

#   ingress {
#     description      = "http access"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   ingress {
#     description      = "https access"
#     from_port        = 443
#     to_port          = 443
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   tags   = {
#     Name = "alb security group"
#   }
# }

# # create security group for the container
# resource "aws_security_group" "ecs_security_group" {
#   name        = "ecs security group"
#   description = "enable http/https access on port 80/443 via alb sg"
#   vpc_id      = var.vpc_id

#   ingress {
#     description      = "http access"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     security_groups  = [aws_security_group.alb_security_group.id]
#   }

#   ingress {
#     description      = "https access"
#     from_port        = 443
#     to_port          = 443
#     protocol         = "tcp"
#     security_groups  = [aws_security_group.alb_security_group.id]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   tags   = {
#     Name = "ecs security group"
#   }
# }