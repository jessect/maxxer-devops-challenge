# vpc module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.10.0"
 
  name = "${var.project}-${var.env}"
  cidr = "10.0.0.0/16"

  create_database_subnet_group = true

  azs               = ["us-east-1a", "us-east-1b"]
  public_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets  = ["10.0.201.0/24", "10.0.202.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
 }

 # eks module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.22.0"

  cluster_version = "1.21"
  cluster_name    = "${var.project}-${var.env}"
  vpc_id          = module.vpc.vpc_id
  subnets         = [ "${element(module.vpc.private_subnets, 0)}", "${element(module.vpc.private_subnets, 1)}" ]

  worker_groups = [
    {
      instance_type = "t2.small"
      asg_max_size  = 2
    }
  ]
}

# sg module - database
module "sg_db" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.4.0"

  name        = "${var.project}-${var.env}-db"
  description = "MySQL security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

}

# rds module
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "3.4.0"

  identifier = "${var.project}-${var.env}"

  engine               = "mysql"
  engine_version       = "8.0.20"
  family               = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false

  name     = var.project
  username = "admin"
  password = random_password.mysql_master_password.result
  port     = 3306

  multi_az               = true
  subnet_ids             = module.vpc.database_subnets
  vpc_security_group_ids = [module.sg_db.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
}