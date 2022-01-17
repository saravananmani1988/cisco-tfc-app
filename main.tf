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

provider "helm" {
  kubernetes {
  host = var.k8s_host

  client_certificate     = var.k8s_client_certificate
  client_key             = var.k8s_client_key
  cluster_ca_certificate = var.k8s_cluster_ca_certificate
  }
}

# Add helm release

resource "helm_release" "petclinic" {
  name       = "my-redis-release"
  repository = "https://platform9-community.github.io/helm-charts"
  chart      = "spring-petclinic-cloud"
  version    = "0.2.1" 


}


