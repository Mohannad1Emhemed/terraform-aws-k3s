# --- root/main.tf ---



module "networking" {
  source           = "./networking"
  vpc_cidr         = local.vpc_cidr
  access_ip        = var.access_ip
  security_groups  = local.security_groups
  public_sn_count  = 3
  private_sn_count = 3
  max_subnets      = 20
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  db_subnet_group  = true
}

module "database" {
  source                 = "./database"
  db_storage             = 10
  db_engine_version      = "8.0.33"
  db_instance_class      = "db.t2.micro"
  dbname                 = var.dbname
  dbuser                 = var.dbuser
  dbpassword             = var.dbpassword
  skip_final_snapshot    = true
  db_subnet_group_name   = module.networking.db_subnet_group_name[0]
  vpc_security_group_ids = module.networking.db_security_group
}

module "loadbalancing" {
  source                 = "./loadbalancing"
  public_sg              = module.networking.lb_security_group
  public_subnets         = module.networking.lb_subnet_group_name
  idle_timeout           = 400
  dev_vpc                = module.networking.vpc_id
  tg_port                = 8000
  tg_protocol            = "HTTP"
  lb_healthy_threshold   = 2
  lb_unhealthy_threshold = 2
  lb_timeout             = 3
  lb_interval            = 30
  listener_port          = 80
  listener_protocol      = "HTTP"
}

module "compute" {
  source              = "./compute"
  public_sg           = module.networking.public_sg
  public_subnets      = module.networking.public_subnets
  instance_count      = 2
  instance_type       = "t3.micro"
  vol_size            = 10
  key_name            = "ec2keypair"
  public_key_path     = "./ec2keypair.pub"
  user_data_path      = "${path.root}/userdata.tpl"
  db_endpoint         = module.database.db_endpoint
  dbpassword          = var.dbpassword
  dbname              = var.dbname
  dbuser              = var.dbuser
  lb_target_group_arn = module.loadbalancing.lb_target_group_arn
  tg_port             = 8000
}
