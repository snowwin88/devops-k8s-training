resource "kubernetes_secret" "app_secret" {
  metadata {
    name      = "${var.app_name}-secret"
    namespace = kubernetes_namespace.dev.metadata[0].name

    labels = {
      app         = var.app_name
      environment = var.environment
      managed-by  = "terraform"
    }
  }

  data = {
    DB_USER     = var.db_user
    DB_PASSWORD = var.db_password
  }

  type = "Opaque"
}
