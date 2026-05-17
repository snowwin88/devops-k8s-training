resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
    labels = {
      environment = "dev"
      managed-by  = "terraform"
    }
  }
}
