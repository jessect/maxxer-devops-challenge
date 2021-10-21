output "db_endpoint" {
  description = "RDS Endpoint"
  value       = module.rds.db_instance_endpoint
}

output "kubeconfig" {
  description = "Create kubeconfig automatically"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${var.project}-${var.env}"
}