resource "kubernetes_horizontal_pod_autoscaler_v2" "hpa" {
  metadata {
    name      = "${var.project}-hpa"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app = var.project
    }
  }
  spec {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas == null ? var.min_replicas + 3 : var.max_replicas

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = "80"
        }
      }
    }

    behavior {
      scale_up {
        stabilization_window_seconds = 180
        select_policy                = "Max"
        policy {
          type           = "Percent"
          value          = 100
          period_seconds = 15
        }
        policy {
          type           = "Pods"
          value          = 4
          period_seconds = 15
        }
      }
      scale_down {
        stabilization_window_seconds = 300
        select_policy                = "Min"
        policy {
          type           = "Percent"
          value          = 100
          period_seconds = 15
        }
      }
    }

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.wordpress.metadata[0].name
    }
  }

  depends_on = [kubernetes_deployment.wordpress]
}
