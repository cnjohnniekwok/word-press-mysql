resource "kubernetes_deployment" "wordpress" {
  metadata {
    name      = var.project
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app = var.project
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.project
      }
    }
    template {
      metadata {
        labels = {
          app = var.project
        }
      }
      spec {
        container {
          image = "wordpress:latest"
          name  = var.project
          env_from {
            secret_ref {
              name = kubernetes_secret.secret.metadata[0].name
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.mysql]
}
