variable "kube_config01" {
  sensitive = true
  type = object({
    host                   = string
    client_certificate     = string
    client_key             = string
    cluster_ca_certificate = string
  })
}

variable "kube_config02" {
  sensitive = true
  type = object({
    host                   = string
    client_certificate     = string
    client_key             = string
    cluster_ca_certificate = string
  })
}

module "platform01" {
  source      = "app.terraform.io/mattias-fjellstrom/kubernetes-platform-module/hashitalks"
  version     = "1.1.0"
  kube_config = var.kube_config01
}

module "platform02" {
  source      = "app.terraform.io/mattias-fjellstrom/kubernetes-platform-module/hashitalks"
  version     = "1.1.0"
  kube_config = var.kube_config02
}
