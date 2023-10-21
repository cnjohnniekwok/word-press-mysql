resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name      = "${var.project}-mysql-pvc"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = "standard"
  }

  depends_on = [kubernetes_namespace.namespace]
}
