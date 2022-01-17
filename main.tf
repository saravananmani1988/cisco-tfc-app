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

resource "kubernetes_deployment" "example" {
  metadata {
    name = "petclinic-db-mysql"
    labels = {
      test = "petclinic-db-mysql"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        test = "petclinic-db-mysql"
      }
    }

    template {
      metadata {
        labels = {
          test = "petclinic-db-mysql"
        }
      }

      spec {
        container {
          image = "mysql:5.7.33"
          name  = "petclinic-db-mysql"
		  env {
            name = "MYSQL_ROOT_PASSWORD"
            value = "supermysql"
          }
		  env {
            name = "MYSQL_PASSWORD"
            value = "supermysql"
          }
		  env {
            name = "MYSQL_USER"
            value = ""
          }
		  env{
            name = "MYSQL_DATABASE"
            value = "petclinic"
          } 
	  
		  port {
            container_port = 3306
			name           = mysql
			protocol	   = TCP
          }
		  
		  liveness_probe {
			exec  {
			  command = "sh -c mysqladmin ping -u root -p${MYSQL_ROOT_PASSWORD}"
			}
			initial_delay_seconds = 30
            period_seconds        = 10
		    failure_threshold     = 3
			success_threshold     = 1
			timeout_seconds       =  5
		  }
		  
		  readiness_probe {
			exec  {
			  command = "sh -c mysqladmin ping -u root -p${MYSQL_ROOT_PASSWORD}"
			}
			initial_delay_seconds = 3
            period_seconds        = 10
		    failure_threshold     = 5
			success_threshold     = 1
			timeout_seconds       =  1
		  }
		  
		  resources {
            limits = {
              cpu    = "100m"
              memory = "256Mi"
            }

           }
		   
		   volume {
		   name = "data"
		   persistent_volume_claim {
		    claim_name = "petclinic-db-mysql"
		   }
		   
		   }
		   
		   volume_mount {
		   
		   mount_path = "/var/lib/mysql"
		   name       = "data"
		   
		   }
      }
    }
  }
}




