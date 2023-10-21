resource "kubernetes_service" "wordpress_svc" {
  metadata {
    name      = "${kubernetes_deployment.wordpress.metadata[0].name}-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app = var.project
    }
  }
  spec {
    selector = {
      app = var.project
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.wordpress]
}

resource "kubernetes_service" "mysql_svc" {
  metadata {
    name      = "${kubernetes_deployment.mysql.metadata[0].name}-service"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app = "${var.project}-mysql"
    }
  }

  spec {
    selector = {
      app = "${var.project}-mysql"
    }

    port {
      port        = 3306
      target_port = 3306
    }

    type = "ClusterIP"
  }
  depends_on = [kubernetes_deployment.mysql]
}
