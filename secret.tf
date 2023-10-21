resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "-"
}

resource "random_password" "db_username" {
  length           = 20
  special          = true
  override_special = "-"
}


resource "kubernetes_secret" "secret" {
  metadata {
    name      = "${var.project}-mysql-secret"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  data = {
    MYSQL_USER            = random_password.db_username.result
    MYSQL_PASSWORD        = random_password.db_password.result
    MYSQL_ROOT_PASSWORD   = random_password.db_password.result
    WORDPRESS_DB_USER     = random_password.db_username.result
    WORDPRESS_DB_PASSWORD = random_password.db_password.result
    WORDPRESS_DB_NAME     = "${var.project}-mysql"
    WORDPRESS_DB_HOST     = "${var.project}-mysql-service"
  }

  depends_on = [kubernetes_namespace.namespace]
}
