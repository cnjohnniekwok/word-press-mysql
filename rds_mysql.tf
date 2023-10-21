resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "${var.project}-mysql"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app = "${var.project}-mysql"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "${var.project}-mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.project}-mysql"
        }
      }

      spec {
        container {
          image = "mysql:latest"
          name  = "${var.project}-mysql"
          args  = ["mysqld", "--character-set-server=utf8", "--collation-server=utf8_general_ci"]
          port {
            container_port = 3306
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.secret.metadata[0].name
            }
          }
          env {
            name  = "MYSQL_DATABASE"
            value = "${var.project}-mysql"
          }
          volume_mount {
            name       = "${var.project}-mysql-persistent-volume"
            mount_path = "/var/lib/mysql"
            sub_path   = "mysql"
          }
        }
        volume {
          name = "${var.project}-mysql-persistent-volume"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.pvc.metadata[0].name
          }
        }
      }
    }
  }
  depends_on = [kubernetes_persistent_volume_claim.pvc]
}
