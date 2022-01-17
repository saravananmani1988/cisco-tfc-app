terraform {
  required_version = ">=0.14.5"

  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.7.1"
    }
  }
}

provider "kubernetes" {
  # Configuration options
  host = var.k8s_host

  client_certificate     = var.k8s_client_certificate
  client_key             = var.k8s_client_key
  cluster_ca_certificate = var.k8s_cluster_ca_certificate
}

# deploy 2 tier app 

resource "kubernetes_persistent_volume_claim" "pvc-petclinic-db-mysql" {
  metadata {
    name = "petclinic-db-mysql"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "8Gi"
      }
    }
    volume_name = "petclinic-db-mysql"
  }
}


