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

resource "kubernetes_deployment" "petclinic-db-mysql" {
  metadata {
    name = "petclinic-db-mysql"
    labels = {
      app = "petclinic-db-mysql"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "petclinic-db-mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "petclinic-db-mysql"
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
          }
		  
		  liveness_probe {
			exec  {
			  command = ["sh", "-c", "mysqladmin ping -u root -psupermysql"]
			}
			initial_delay_seconds = 30
            period_seconds        = 10
		    failure_threshold     = 3
			success_threshold     = 1
			timeout_seconds       =  5
		  }
		  
		  readiness_probe {
			exec  {
  			  command = ["sh", "-c", "mysqladmin ping -u root -psupermysql"]
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

		   
		   volume_mount {
		   
		   mount_path = "/var/lib/mysql"
		   name       = "data"
		   
		   }
      }
	  
        init_container {
          name              = "remove-lost-found"
          image             = "busybox:1.29.3"
          image_pull_policy = "IfNotPresent"
          command           = ["rm", "-fr", "/var/lib/mysql/lost+found"]

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/mysql"
            sub_path   = ""
          }
        }
      volume {
	   name = "data"
	   persistent_volume_claim {
		claim_name = "petclinic-db-mysql"
	   }
	   
	   }
		   
    }
  }
 }
}

# create mysql DB service 

resource "kubernetes_service" "petclinic-db-mysql" {
  metadata {
    name = "petclinic-db-mysql"
  }
  spec {
    selector = {
      app = "petclinic-db-mysql"
    }
    session_affinity = "None"
    port {
      port        = 3306
      target_port = "mysql"
	  protocol = "TCP"
    }

    type = "ClusterIP"
  }
}



# Deploy front end 

resource "kubernetes_deployment" "petclinic" {
  metadata {
    name = "petclinic"
    labels = {
      app = "petclinic"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "petclinic"
      }
    }

    template {
      metadata {
        labels = {
          app = "petclinic"
        }
      }

      spec {
        container {
          image = "springdeveloper/spring-petclinic:2.0.0.BUILD-SNAPSHOT"
		  image_pull_policy = "IfNotPresent"
          name  = "petclinic"
		  env {
            name = "MYSQL_HOST"
            value = "petclinic-db-mysql"
          }
		  env {
            name = "MYSQL_PASSWORD"
            value = "supermysql"
          }
		  env {
            name = "MYSQL_USERNAME"
            value = "root"
          }
		  env{
            name = "SPRING_PROFILES_ACTIVE"
            value = "production,kubernetes"
          } 
	  
		  port {
            container_port = 80
          }
		  
		  liveness_probe {
			http_get  {
			  path  = "/manage/health"
			  port  = 8080
			}
			initial_delay_seconds = 60
            period_seconds        = 10
		  }
		  
		  readiness_probe {
			http_get  {
			  path  = "/manage/health"
			  port  = 8080
			}
			initial_delay_seconds = 15
            period_seconds        = 5
		  }
 
      }  
		   
    }
  }
 }
}

# create petclinic UI service 

resource "kubernetes_service" "petclinic" {
  metadata {
    name = "petclinic"
  }
  spec {
    selector = {
      app = "petclinic"
    }
    session_affinity = "None"
    port {
      port        = 80
      target_port = 8080
	  protocol = "TCP"
	  node_port = 30333
    }

    type = "NodePort"
  }
}

