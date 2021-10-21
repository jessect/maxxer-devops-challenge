# secrets - mysql master password
resource "random_password" "master_password" {
  length  = 16
  special = false
}

# secrets manager
resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "${var.project}-${var.env}-credentials"
}

# store rds credentials
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