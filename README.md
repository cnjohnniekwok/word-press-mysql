## Simple RDS - Wordpress to Kubernates deployment

In this repository you will find all the kubernates resources I've create for the  wordpress. Here I deploy MySQL database to act as the RDS required for this wordpress servers.

Since this is a local setup of a kubernates deployment, I only use one variable `var.project` to illustrate the re-reusability there's 2 other optional variables for HPA usage. We can update this variable to re-deploy as a module to another kubernate cluster. Usually there will be more such as access key, token, or some other project aspects variable. Since this is created for demonstration purpose, I export the `TF_VAR_project` as an local environment variable for terrafrom to read.

The kubernate resources will deploy in the following sequence:
1. namespace
2. presistent_volume_claim & secrets
3. rds_mysql
4. wordpress
5. services & horizontal_pod_autoscaler

## Secrets
To further automate Wordpress & Mysql database initial configuration, I have an option to assign `WORDPRESS.*` and `MYSQL.*` environment variables to store the database credentials.

I use `random_password` to generate random string for `db_username` and `db_password`. Putting them in a k8s secrets and pass it as environment variables for both deployments (mysql & wordpress). Avoiding plain text secret being expose in the tf plan.

If we are deploying an `aws_db_instance`, we will be looking a `awk_kms_key` for secret management

In this demonstration, the database host is pointing to the MySQL database k8s service. That can be update to point to an AWS RDS as well.

## To run it locally
Local setup:
1. Clone this repository
2. Install Docker, Minikube
3. cd into [path-to-dir]/word-press-mysql

Run the following commands:
1. export TF_VAR_project=click-dealer-wordpress
2. minikube start
3. terraform init
4. terraform plan
5. terraform apply --auto-approve
6. kubectl port-forward -n $TF_VAR_project [wordpress-pod-name] 5678:80

Visit the frontend at `http://localhost:5678`

## Run it as a module
Local setup:
1. Install Docker, Minikube
2. Edit and save the following module block
```
module "wordpress-mysql" {
  source = "git::https://github.com/cnjohnniekwok/word-press-mysql.git"
  project = "wordpress-deployment-with-module"
}
```
3. minikube start
4. terraform init
5. terraform plan
6. terraform apply --auto-approve
7. kubectl port-forward -n wordpress-deployment-with-module [wordpress-pod-name] 5678:80

Visit the frontend at `http://localhost:5678`

Below is a screen shot of terrafrom plan output using module:
![Alt text](./screenshots/Screenshot%202023-10-21%20at%2016.42.03.png?raw=true "terraform apply output")

**Please note:** For HPA to work in minikube, make sure enabling the metic server by running the following command:
```
minikube addons enable metrics-server
```
![Alt text](./screenshots/Screenshot%202023-10-21%20at%2019.16.27.png?raw=true "terraform apply output")


## Terraform Plan

```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # kubernetes_deployment.mysql will be created
  + resource "kubernetes_deployment" "mysql" {
      + id               = (known after apply)
      + wait_for_rollout = true

      + metadata {
          + generation       = (known after apply)
          + labels           = {
              + "app" = "click-dealer-wordpress-mysql"
            }
          + name             = "click-dealer-wordpress-mysql"
          + namespace        = "click-dealer-wordpress"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }

      + spec {
          + min_ready_seconds         = 0
          + paused                    = false
          + progress_deadline_seconds = 600
          + replicas                  = "1"
          + revision_history_limit    = 10

          + selector {
              + match_labels = {
                  + "app" = "click-dealer-wordpress-mysql"
                }
            }

          + strategy {
              + type = (known after apply)

              + rolling_update {
                  + max_surge       = (known after apply)
                  + max_unavailable = (known after apply)
                }
            }

          + template {
              + metadata {
                  + generation       = (known after apply)
                  + labels           = {
                      + "app" = "click-dealer-wordpress-mysql"
                    }
                  + name             = (known after apply)
                  + resource_version = (known after apply)
                  + uid              = (known after apply)
                }

              + spec {
                  + automount_service_account_token  = true
                  + dns_policy                       = "ClusterFirst"
                  + enable_service_links             = true
                  + host_ipc                         = false
                  + host_network                     = false
                  + host_pid                         = false
                  + hostname                         = (known after apply)
                  + node_name                        = (known after apply)
                  + restart_policy                   = "Always"
                  + scheduler_name                   = (known after apply)
                  + service_account_name             = (known after apply)
                  + share_process_namespace          = false
                  + termination_grace_period_seconds = 30

                  + container {
                      + args                       = [
                          + "mysqld",
                          + "--character-set-server=utf8",
                          + "--collation-server=utf8_general_ci",
                        ]
                      + image                      = "mysql:latest"
                      + image_pull_policy          = (known after apply)
                      + name                       = "click-dealer-wordpress-mysql"
                      + stdin                      = false
                      + stdin_once                 = false
                      + termination_message_path   = "/dev/termination-log"
                      + termination_message_policy = (known after apply)
                      + tty                        = false

                      + env {
                          + name  = "MYSQL_DATABASE"
                          + value = "click-dealer-wordpress-mysql"
                        }

                      + env_from {

                          + secret_ref {
                              + name = "click-dealer-wordpress-mysql-secret"
                            }
                        }

                      + port {
                          + container_port = 3306
                          + protocol       = "TCP"
                        }

                      + resources {
                          + limits   = (known after apply)
                          + requests = (known after apply)
                        }

                      + volume_mount {
                          + mount_path        = "/var/lib/mysql"
                          + mount_propagation = "None"
                          + name              = "click-dealer-wordpress-mysql-persistent-volume"
                          + read_only         = false
                          + sub_path          = "mysql"
                        }
                    }

                  + image_pull_secrets {
                      + name = (known after apply)
                    }

                  + readiness_gate {
                      + condition_type = (known after apply)
                    }

                  + volume {
                      + name = "click-dealer-wordpress-mysql-persistent-volume"

                      + persistent_volume_claim {
                          + claim_name = "click-dealer-wordpress-mysql-pvc"
                          + read_only  = false
                        }
                    }
                }
            }
        }
    }

  # kubernetes_deployment.wordpress will be created
  + resource "kubernetes_deployment" "wordpress" {
      + id               = (known after apply)
      + wait_for_rollout = true

      + metadata {
          + generation       = (known after apply)
          + labels           = {
              + "app" = "click-dealer-wordpress"
            }
          + name             = "click-dealer-wordpress"
          + namespace        = "click-dealer-wordpress"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }

      + spec {
          + min_ready_seconds         = 0
          + paused                    = false
          + progress_deadline_seconds = 600
          + replicas                  = "1"
          + revision_history_limit    = 10

          + selector {
              + match_labels = {
                  + "app" = "click-dealer-wordpress"
                }
            }

          + strategy {
              + type = (known after apply)

              + rolling_update {
                  + max_surge       = (known after apply)
                  + max_unavailable = (known after apply)
                }
            }

          + template {
              + metadata {
                  + generation       = (known after apply)
                  + labels           = {
                      + "app" = "click-dealer-wordpress"
                    }
                  + name             = (known after apply)
                  + resource_version = (known after apply)
                  + uid              = (known after apply)
                }

              + spec {
                  + automount_service_account_token  = true
                  + dns_policy                       = "ClusterFirst"
                  + enable_service_links             = true
                  + host_ipc                         = false
                  + host_network                     = false
                  + host_pid                         = false
                  + hostname                         = (known after apply)
                  + node_name                        = (known after apply)
                  + restart_policy                   = "Always"
                  + scheduler_name                   = (known after apply)
                  + service_account_name             = (known after apply)
                  + share_process_namespace          = false
                  + termination_grace_period_seconds = 30

                  + container {
                      + image                      = "wordpress:latest"
                      + image_pull_policy          = (known after apply)
                      + name                       = "click-dealer-wordpress"
                      + stdin                      = false
                      + stdin_once                 = false
                      + termination_message_path   = "/dev/termination-log"
                      + termination_message_policy = (known after apply)
                      + tty                        = false

                      + env_from {

                          + secret_ref {
                              + name = "click-dealer-wordpress-mysql-secret"
                            }
                        }

                      + liveness_probe {
                          + failure_threshold     = 3
                          + initial_delay_seconds = 30
                          + period_seconds        = 15
                          + success_threshold     = 1
                          + timeout_seconds       = 1

                          + http_get {
                              + path   = "/"
                              + port   = "80"
                              + scheme = "HTTP"
                            }
                        }

                      + resources {
                          + limits   = {
                              + "cpu"    = "0.5"
                              + "memory" = "512Mi"
                            }
                          + requests = {
                              + "cpu"    = "250m"
                              + "memory" = "50Mi"
                            }
                        }
                    }

                  + image_pull_secrets {
                      + name = (known after apply)
                    }

                  + readiness_gate {
                      + condition_type = (known after apply)
                    }
                }
            }
        }
    }

  # kubernetes_horizontal_pod_autoscaler_v2.hpa will be created
  + resource "kubernetes_horizontal_pod_autoscaler_v2" "hpa" {
      + id = (known after apply)

      + metadata {
          + generation       = (known after apply)
          + labels           = {
              + "app" = "click-dealer-wordpress"
            }
          + name             = "click-dealer-wordpress-hpa"
          + namespace        = "click-dealer-wordpress"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }

      + spec {
          + max_replicas                      = 4
          + min_replicas                      = 1
          + target_cpu_utilization_percentage = (known after apply)

          + behavior {
              + scale_down {
                  + select_policy                = "Min"
                  + stabilization_window_seconds = 300

                  + policy {
                      + period_seconds = 15
                      + type           = "Percent"
                      + value          = 100
                    }
                }

              + scale_up {
                  + select_policy                = "Max"
                  + stabilization_window_seconds = 180

                  + policy {
                      + period_seconds = 15
                      + type           = "Percent"
                      + value          = 100
                    }
                  + policy {
                      + period_seconds = 15
                      + type           = "Pods"
                      + value          = 4
                    }
                }
            }

          + metric {
              + type = "Resource"

              + resource {
                  + name = "cpu"

                  + target {
                      + average_utilization = 80
                      + type                = "Utilization"
                    }
                }
            }

          + scale_target_ref {
              + api_version = "apps/v1"
              + kind        = "Deployment"
              + name        = "click-dealer-wordpress"
            }
        }
    }

  # kubernetes_namespace.namespace will be created
  + resource "kubernetes_namespace" "namespace" {
      + id                               = (known after apply)
      + wait_for_default_service_account = false

      + metadata {
          + annotations      = {
              + "name" = "click-dealer-wordpress"
            }
          + generation       = (known after apply)
          + labels           = {
              + "namespace" = "click-dealer-wordpress"
            }
          + name             = "click-dealer-wordpress"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }
    }

  # kubernetes_persistent_volume_claim.pvc will be created
  + resource "kubernetes_persistent_volume_claim" "pvc" {
      + id               = (known after apply)
      + wait_until_bound = true

      + metadata {
          + generation       = (known after apply)
          + name             = "click-dealer-wordpress-mysql-pvc"
          + namespace        = "click-dealer-wordpress"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }

      + spec {
          + access_modes       = [
              + "ReadWriteOnce",
            ]
          + storage_class_name = "standard"
          + volume_name        = (known after apply)

          + resources {
              + requests = {
                  + "storage" = "1Gi"
                }
            }
        }
    }

  # kubernetes_secret.secret will be created
  + resource "kubernetes_secret" "secret" {
      + data                           = (sensitive value)
      + id                             = (known after apply)
      + type                           = "Opaque"
      + wait_for_service_account_token = true

      + metadata {
          + generation       = (known after apply)
          + name             = "click-dealer-wordpress-mysql-secret"
          + namespace        = "click-dealer-wordpress"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }
    }

  # kubernetes_service.mysql_svc will be created
  + resource "kubernetes_service" "mysql_svc" {
      + id                     = (known after apply)
      + status                 = (known after apply)
      + wait_for_load_balancer = true

      + metadata {
          + generation       = (known after apply)
          + labels           = {
              + "app" = "click-dealer-wordpress-mysql"
            }
          + name             = "click-dealer-wordpress-mysql-service"
          + namespace        = "click-dealer-wordpress"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }

      + spec {
          + allocate_load_balancer_node_ports = true
          + cluster_ip                        = (known after apply)
          + cluster_ips                       = (known after apply)
          + external_traffic_policy           = (known after apply)
          + health_check_node_port            = (known after apply)
          + internal_traffic_policy           = (known after apply)
          + ip_families                       = (known after apply)
          + ip_family_policy                  = (known after apply)
          + publish_not_ready_addresses       = false
          + selector                          = {
              + "app" = "click-dealer-wordpress-mysql"
            }
          + session_affinity                  = "None"
          + type                              = "ClusterIP"

          + port {
              + node_port   = (known after apply)
              + port        = 3306
              + protocol    = "TCP"
              + target_port = "3306"
            }

          + session_affinity_config {
              + client_ip {
                  + timeout_seconds = (known after apply)
                }
            }
        }
    }

  # kubernetes_service.wordpress_svc will be created
  + resource "kubernetes_service" "wordpress_svc" {
      + id                     = (known after apply)
      + status                 = (known after apply)
      + wait_for_load_balancer = true

      + metadata {
          + generation       = (known after apply)
          + labels           = {
              + "app" = "click-dealer-wordpress"
            }
          + name             = "click-dealer-wordpress-service"
          + namespace        = "click-dealer-wordpress"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }

      + spec {
          + allocate_load_balancer_node_ports = true
          + cluster_ip                        = (known after apply)
          + cluster_ips                       = (known after apply)
          + external_traffic_policy           = (known after apply)
          + health_check_node_port            = (known after apply)
          + internal_traffic_policy           = (known after apply)
          + ip_families                       = (known after apply)
          + ip_family_policy                  = (known after apply)
          + publish_not_ready_addresses       = false
          + selector                          = {
              + "app" = "click-dealer-wordpress"
            }
          + session_affinity                  = "None"
          + type                              = "ClusterIP"

          + port {
              + node_port   = (known after apply)
              + port        = 80
              + protocol    = "TCP"
              + target_port = "80"
            }

          + session_affinity_config {
              + client_ip {
                  + timeout_seconds = (known after apply)
                }
            }
        }
    }

  # random_password.db_password will be created
  + resource "random_password" "db_password" {
      + bcrypt_hash      = (sensitive value)
      + id               = (known after apply)
      + length           = 20
      + lower            = true
      + min_lower        = 0
      + min_numeric      = 0
      + min_special      = 0
      + min_upper        = 0
      + number           = true
      + numeric          = true
      + override_special = "-"
      + result           = (sensitive value)
      + special          = true
      + upper            = true
    }

  # random_password.db_username will be created
  + resource "random_password" "db_username" {
      + bcrypt_hash      = (sensitive value)
      + id               = (known after apply)
      + length           = 20
      + lower            = true
      + min_lower        = 0
      + min_numeric      = 0
      + min_special      = 0
      + min_upper        = 0
      + number           = true
      + numeric          = true
      + override_special = "-"
      + result           = (sensitive value)
      + special          = true
      + upper            = true
    }

Plan: 10 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

## Terraform Apply output:
![Alt text](./screenshots/Screenshot%202023-10-21%20at%2019.43.45.png?raw=true "terraform apply output")

## Wordpress and database deployment @ click-dealer namespace:
![Alt text](./screenshots/Screenshot%202023-10-21%20at%2014.17.15.png?raw=true "terraform apply output")


### Port Forwarding to wordpress pod:
Wordpress started with database configured.

![Alt text](./screenshots/Screenshot%202023-10-21%20at%2014.19.59.png?raw=true "terraform apply output")

### Wordpress admin page:
![Alt text](./screenshots/Screenshot%202023-10-21%20at%2014.20.28.png?raw=true "terraform apply output")

## Liveness Prob and HPA Test
Set Liveness Prob to listen on port `1234` instead of `80`. [WORKS!]
![Alt text](./screenshots/Screenshot%202023-10-21%20at%2019.20.53.png?raw=true "terraform apply output")

Pod restarted due to liveness prob failure.
![Alt text](./screenshots/Screenshot%202023-10-21%20at%2019.21.22.png?raw=true "terraform apply output")


Set HPA to scale to max when CPU is over 1% [WORKS!] It scales to 4 pods.
![Alt text](./screenshots/Screenshot%202023-10-21%20at%2019.24.00.png?raw=true "terraform apply output")
