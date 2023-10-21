resource "kubernetes_namespace" "namespace" {
  metadata {
    annotations = {
      name = var.project
    }

    labels = {
      namespace = var.project
    }

    name = var.project
  }
}
