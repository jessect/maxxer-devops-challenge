output "kubeconfig" {
  description = "Create kubeconfig automatically"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${var.project}-${var.env}"
}

output "database_host" {
  description = "Show database address"
  value       = module.rds.db_instance_address
}

output "database_name" {
  description = "Show database name"
  value       = module.rds.db_instance_name
}

output "database_admin_user" {
  description = "Show database username"
  value       = module.rds.db_instance_username
  sensitive   = true
}

output "database_master_password" {
  description = "Show database master password"
  value       = random_password.master_password.result
  sensitive   = true
}

#output "clone_url_https" {
#  value = aws_codecommit_repository.repo.clone_url_http
#}
#
#output "clone_url_ssh" {
#  value = aws_codecommit_repository.repo.clone_url_ssh
#}
#
#
#output "repository_url" {
#  value = aws_ecr_repository.ecr.repository_url
#}
#
#output "registry_id" {
#  value = aws_ecr_repository.ecr.registry_id
#}
#
