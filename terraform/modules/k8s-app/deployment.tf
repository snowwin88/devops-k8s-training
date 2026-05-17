resource "kubernetes_deployment" "app" {
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
    replicas = var.replica_count

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app         = var.app_name
          environment = var.environment
        }
      }

      spec {
        container {
          name              = var.app_name
          image             = "${var.image_repository}:${var.image_tag}"
          image_pull_policy = var.image_pull_policy

          port {
            container_port = var.container_port
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.app_config.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.app_secret.metadata[0].name
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = var.container_port
            }

            initial_delay_seconds = 5
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/"
              port = var.container_port
            }

            initial_delay_seconds = 15
            period_seconds        = 20
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }

            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}
