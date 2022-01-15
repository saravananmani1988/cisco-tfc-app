variable "apikey" {
  type        = string
  description = "API Key"
}
variable "secretkey" {
  type        = string
  description = "Secret Key or file location"
}
variable "endpoint" {
  type        = string
  description = "API Endpoint URL"
  default     = "https://www.intersight.com"
}
variable "organization" {
  type        = string
  description = "Organization Name"
  default     = "default"
}
variable "ssh_user" {
  type        = string
  description = "SSH Username for node login."
}
variable "ssh_key" {
  type        = string
  description = "SSH Public Key to be used to node login."
}
variable "tags" {
  type    = list(map(string))
  default = []
}
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
