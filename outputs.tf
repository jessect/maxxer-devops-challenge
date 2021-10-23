output "kubeconfig" {
  description = "Create kubeconfig automatically"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${var.project}-${var.env}"
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
#output "db_endpoint" {
#  description = "RDS Endpoint"
#  value       = module.rds.db_instance_endpoint
#}
