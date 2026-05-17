resource "kubernetes_service" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.dev.metadata[0].name

    labels = {
      app         = var.app_name
      environment = var.environment
      managed-by  = "terraform"
    }
  }

  spec {
    selector = {
      app = var.app_name
    }

    port {
      protocol    = "TCP"
      port        = var.service_port
      target_port = var.container_port
    }

    type = var.service_type
  }
}
