terraform {
  required_version = "~> 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.88.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.4.1"
    }
  }
}

provider "azurerm" {
  features {}
}

# module "resource_group" {
#   source = "../terraform-hashitalks-resource-group-module"

#   name_suffix = "hashitalks"
#   location    = "swedencentral"
#   tags = {
#     team        = "HashiTalks Team"
#     project     = "HashiTalks Project"
#     cost_center = "1234"
#   }
# }

# module "virtual_network" {
#   source          = "../terraform-hashitalks-network-module"
#   name_suffix     = "hashitalks"
#   resource_group  = module.resource_group.resource_group
#   vnet_cidr_range = "10.0.0.0/16"
#   subnets = [
#     {
#       name              = "aks01"
#       subnet_cidr_range = "10.0.10.0/24"
#     },
#     {
#       name              = "aks02"
#       subnet_cidr_range = "10.0.20.0/24"
#     }
#   ]
# }

# module "aks01" {
#   source                   = "../terraform-hashitalks-aks-module"
#   resource_group           = module.resource_group.resource_group
#   subnet                   = module.virtual_network.subnets[0]
#   environment              = "prod"
#   name_suffix              = "hashitalks-aks01"
#   node_resource_group_name = "rg-aks-01-node-resources"
# }

# module "aks02" {
#   source                   = "../terraform-hashitalks-aks-module"
#   resource_group           = module.resource_group.resource_group
#   subnet                   = module.virtual_network.subnets[1]
#   environment              = "prod"
#   name_suffix              = "hashitalks-aks02"
#   node_resource_group_name = "rg-aks-02-node-resources"
# }

# module "platform01" {
#   source      = "../terraform-hashitalks-kubernetes-platform-module"
#   kube_config = module.aks01.kube_config
# }

# module "platform02" {
#   source      = "../terraform-hashitalks-kubernetes-platform-module"
#   kube_config = module.aks02.kube_config
# }

# provider "kubernetes" {
#   alias                  = "kubernetes01"
#   host                   = module.aks01.kube_config.host
#   client_certificate     = base64decode(module.aks01.kube_config.client_certificate)
#   client_key             = base64decode(module.aks01.kube_config.client_key)
#   cluster_ca_certificate = base64decode(module.aks01.kube_config.cluster_ca_certificate)
# }

# provider "kubernetes" {
#   alias                  = "kubernetes02"
#   host                   = module.aks02.kube_config.host
#   client_certificate     = base64decode(module.aks02.kube_config.client_certificate)
#   client_key             = base64decode(module.aks02.kube_config.client_key)
#   cluster_ca_certificate = base64decode(module.aks02.kube_config.cluster_ca_certificate)
# }

# # STEP 2: SET UP SAMPLE APPLICATIONS
# module "sample_app01" {
#   source = "../terraform-hashitalks-starter-application"
#   providers = {
#     kubernetes = kubernetes.kubernetes01
#   }
#   depends_on = [module.platform01]
#   revision   = "main"
# }

# module "sample_app02" {
#   source = "../terraform-hashitalks-starter-application"
#   providers = {
#     kubernetes = kubernetes.kubernetes02
#   }
#   depends_on = [module.platform02]
#   revision   = "feat/v2"
# }

# # STEP 3: QUERY FOR SERVICE IPS AND SET UP TRAFFIC MANAGER
# module "helper_app01" {
#   source      = "./helper/service-ip"
#   kube_config = module.aks01.kube_config
# }

# module "helper_app02" {
#   source      = "./helper/service-ip"
#   kube_config = module.aks02.kube_config
# }

# module "traffic_manager" {
#   source         = "../terraform-hashitalks-traffic-manager-module"
#   resource_group = module.resource_group.resource_group
#   name_suffix    = "hashitalks"
#   endpoints = [
#     {
#       name     = "aks01"
#       target   = module.helper_app01.service_ip
#       priority = 100
#       enabled  = true
#     },
#     {
#       name     = "aks02"
#       target   = module.helper_app02.service_ip
#       priority = 200
#       enabled  = false
#     }
#   ]
# }

# module "poll" {
#   source  = "./helper/http"
#   fqdn    = module.traffic_manager.traffic_manager_profile.fqdn
#   trigger = "test2"
# }

# output "test" {
#   value = module.poll.response
# }

# # STEP 4: SWAP --^
