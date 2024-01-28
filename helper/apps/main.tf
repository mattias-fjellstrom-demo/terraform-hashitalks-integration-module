terraform {
  required_providers {
    kubernetes = {
      source                = "hashicorp/kubernetes"
      version               = "2.25.2"
      configuration_aliases = [kubernetes.cluster01, kubernetes.cluster02]
    }
  }
}

module "app01" {
  source   = "app.terraform.io/mattias-fjellstrom/starter-application-module/hashitalks"
  version  = "1.0.0"
  revision = "main"
  providers = {
    kubernetes = kubernetes.cluster01
  }
}

module "app02" {
  source   = "app.terraform.io/mattias-fjellstrom/starter-application-module/hashitalks"
  version  = "1.0.0"
  revision = "feat/v2"
  providers = {
    kubernetes = kubernetes.cluster02
  }
}
