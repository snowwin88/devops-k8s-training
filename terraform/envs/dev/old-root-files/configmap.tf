resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "${var.app_name}-config"
    namespace = kubernetes_namespace.dev.metadata[0].name

    labels = {
      app         = var.app_name
      environment = var.environment
      managed-by  = "terraform"
    }
  }

  data = {
    APP_ENV   = var.app_env
    LOG_LEVEL = var.log_level
  }
}
