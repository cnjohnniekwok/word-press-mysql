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

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }

            initial_delay_seconds = 30
            period_seconds        = 15
          }
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
