variable "k8s_host" {
  type        = string
  description = "K8s cluster API server IP or host name"
}
variable "k8s_client_certificate" {
  type        = string
  description = "K8s client cert"
}
variable "k8s_client_key" {
  type        = string
  description = "k8s client cert key"
}
variable "k8s_cluster_ca_certificate" {
  type        = string
  description = "k8s ca server cert."
}
