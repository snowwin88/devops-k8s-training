output "namespace" {
  description = "Kubernetes namespace created by Terraform"
  value       = kubernetes_namespace.dev.metadata[0].name
}

output "app_name" {
  description = "Application name"
  value       = var.app_name
}

output "deployment_name" {
  description = "Kubernetes Deployment name"
  value       = kubernetes_deployment.app.metadata[0].name
}

output "service_name" {
  description = "Kubernetes Service name"
  value       = kubernetes_service.app.metadata[0].name
}
