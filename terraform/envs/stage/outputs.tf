output "namespace" {
  description = "Kubernetes namespace"
  value       = module.demo_app.namespace
}

output "app_name" {
  description = "Application name"
  value       = module.demo_app.app_name
}

output "deployment_name" {
  description = "Kubernetes deployment name"
  value       = module.demo_app.deployment_name
}

output "service_name" {
  description = "Kubernetes service name"
  value       = module.demo_app.service_name
}
