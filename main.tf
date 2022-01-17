terraform {
  required_version = ">=0.14.5"

  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.7.1"
    }
  }
}

# provider "intersight" {
#   apikey    = var.apikey
#   secretkey = var.secretkey
#   endpoint  = var.endpoint
# }


# data intersight_kubernetes_cluster "iks_cluster" {
# }

# output "iks_data" {
#  value = data.intersight_kubernetes_cluster.iks_cluster.results[1]
# }

# output "iks_data1" {
#  value = data.intersight_kubernetes_cluster.iks_cluster.results[1].kube_config
# }

# output "iks_data_decode" {
#   value = base64decode(data.intersight_kubernetes_cluster.iks_cluster.results[1].kube_config)
# }

provider "kubernetes" {
  # Configuration options
  host = var.k8s_host

  client_certificate     = var.k8s_client_certificate
  client_key             = var.k8s_client_key
  cluster_ca_certificate = var.k8s_cluster_ca_certificate
}

# deploy a sample app

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "terraform-example"
    labels = {
      test = "nginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        test = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          test = "nginx"
        }
      }

      spec {
        container {
          image = "nginx:1.7.8"
          name  = "nginx"

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
              path = "/nginx_status"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}
