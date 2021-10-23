# mysql master password
resource "random_password" "master_password" {
  length  = 16
  special = false
}

# app password
resource "random_password" "app_password" {
  length  = 16
  special = false
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
  password = random_password.master_password.result
  port     = 3306

  multi_az               = true
  subnet_ids             = module.vpc.private_subnets
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


# unique id for credentials
resource "random_id" "rds" {
  byte_length = 4
}

resource "random_id" "app" {
  byte_length = 4
}

# store rds credentials
resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "${var.project}-${var.env}-rds-credentials-${random_id.rds.id}"
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = <<EOF
{
  "username": "${module.rds.db_instance_username}",
  "password": "${random_password.master_password.result}",
  "engine": "mysql",
  "host": "${module.rds.db_instance_address}",
  "port": "${module.rds.db_instance_port}",
  "dbname": "${module.rds.db_instance_name}",
  "dbClusterIdentifier": "${module.rds.db_instance_id}"
}
EOF
}

# store app credentials
resource "aws_secretsmanager_secret" "app_credentials" {
  name = "${var.project}-${var.repo_name}-${var.env}-credentials-${random_id.rds.id}"
}

resource "aws_secretsmanager_secret_version" "app_credentials" {
  secret_id     = aws_secretsmanager_secret.app_credentials.id
  secret_string = <<EOF
{
  "username": "${var.app_user}",
  "password": "${random_password.app_password.result}",
}
EOF
}

# create db user
resource "null_resource" "db_user" {
  provisioner "local-exec" {
    command = <<EOT
    kubectl run db-init --image=mysql:8 -it --rm --restart=Never -- mysql \
    --host=${module.rds.db_instance_address} \
    --port=${module.rds.db_instance_port} \
    --user=${module.rds.db_instance_username} \
    --password=${random_password.master_password.result} -e "\
    CREATE USER '${var.app_user}'@'%' IDENTIFIED BY '${random_password.app_password.result}'; \
    GRANT ALL PRIVILEGES ON ${var.project} . * TO '${var.app_user}'@'%';"
    EOT
  }
  depends_on = [module.rds.endpoint]
}
