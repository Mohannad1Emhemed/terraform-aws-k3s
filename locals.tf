locals {
  vpc_cidr = "10.32.0.0/16"
}

locals {
  security_groups = {
    public = {
      name        = "public_sg"
      description = "Security Group for public Access"
      ingress = {
        all = {
          from        = 0
          to          = 0
          protocol    = "-1"
          cidr_blocks = [var.access_ip]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        nginx = {
          from        = 8000
          to          = 8000
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
      egress = {
        outbound = {
          from        = 0
          to          = 0
          protocol    = "-1"
          cidr_blocks = [var.access_ip]
        }
      }
    }
    rds = {
      name        = "rds_sg"
      description = "Security Group for RDS Access"
      ingress = {
        mysql = {
          from        = 3306
          to          = 3306
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
      }
      egress = {
        outbound = {
          from        = 0
          to          = 0
          protocol    = "-1"
          cidr_blocks = [local.vpc_cidr]
        }
      }
    }
  }
}

locals {
  health_check = {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    tg_port             = 80
    vpc_id              = module.networking.vpc_id
    tg_protocol         = "HTTP"
  }
}