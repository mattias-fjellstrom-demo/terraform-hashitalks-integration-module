terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.88.0"
    }
  }
}

variable "resource_group" {
  type = object({
    name     = string
    location = string
    tags     = map(string)
  })
}

variable "subnet01" {
  type = object({
    id = string
  })
}

variable "subnet02" {
  type = object({
    id = string
  })
}

module "cluster01" {
  source                   = "app.terraform.io/mattias-fjellstrom/aks-module/hashitalks"
  version                  = "2.0.0"
  environment              = "prod"
  name_suffix              = "aks01"
  resource_group           = var.resource_group
  subnet                   = var.subnet01
  node_resource_group_name = "rg-cluster01-node-resources"
}

module "cluster02" {
  source                   = "app.terraform.io/mattias-fjellstrom/aks-module/hashitalks"
  version                  = "2.0.0"
  environment              = "prod"
  name_suffix              = "aks02"
  resource_group           = var.resource_group
  subnet                   = var.subnet02
  node_resource_group_name = "rg-cluster02-node-resources"
}

output "cluster01_kubeconfig" {
  value     = module.cluster01.kube_config
  sensitive = true
}

output "cluster02_kubeconfig" {
  value     = module.cluster02.kube_config
  sensitive = true
}
