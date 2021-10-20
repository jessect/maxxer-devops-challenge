output "kubeconfig" {
  description = "Create kubeconfig automatically"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${var.project}-${var.env}"
}