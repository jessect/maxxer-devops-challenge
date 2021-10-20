# secrets - mysql master password
resource "random_password" "mysql_master_password" {
  length  = 16
  special = false
}