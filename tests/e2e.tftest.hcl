//------------------------------------------------------------------------------
// CONFIGURE INITIAL PROVIDERS
//------------------------------------------------------------------------------
provider "azurerm" {
  features {}
}

//------------------------------------------------------------------------------
// CONFIGURE COMMON GLOBAL VARIABLES
//------------------------------------------------------------------------------
variables {
  name_suffix = "hashitalks2024"
}

//------------------------------------------------------------------------------
// SET UP A RESOURCE GROUP
//------------------------------------------------------------------------------
run "setup_resource_group" {
  variables {
    location = "swedencentral"
    tags = {
      team        = "HashiTalks Team"
      project     = "HashiTalks Project"
      cost_center = "1234"
    }
  }

  module {
    source  = "app.terraform.io/mattias-fjellstrom/resource-group-module/hashitalks"
    version = "3.1.0"
  }
}

//------------------------------------------------------------------------------
// SET UP A VIRTUAL NETWORK
//------------------------------------------------------------------------------
run "setup_virtual_network" {
  variables {
    resource_group  = run.setup_resource_group.resource_group
    vnet_cidr_range = "10.0.0.0/16"
    subnets = [
      {
        name              = "aks01"
        subnet_cidr_range = "10.0.10.0/24"
      },
      {
        name              = "aks02"
        subnet_cidr_range = "10.0.20.0/24"
      }
    ]
  }

  module {
    source  = "app.terraform.io/mattias-fjellstrom/network-module/hashitalks"
    version = "3.0.0"
  }
}

//------------------------------------------------------------------------------
// SET UP TWO AKS CLUSTERS USING A HELPER MODULE
//------------------------------------------------------------------------------
run "setup_clusters" {
  variables {
    resource_group = run.setup_resource_group.resource_group
    subnet01       = run.setup_virtual_network.subnets[0]
    subnet02       = run.setup_virtual_network.subnets[1]
  }

  module {
    source = "./helper/cluster"
  }
}

//------------------------------------------------------------------------------
// SET UP ARGO CD ON THE TWO CLUSTERS USING A HELPER MODULE
//------------------------------------------------------------------------------
run "setup_kubernetes_platforms" {
  variables {
    kube_config01 = run.setup_clusters.cluster01_kubeconfig
    kube_config02 = run.setup_clusters.cluster02_kubeconfig
  }

  module {
    source = "./helper/platform"
  }
}

//------------------------------------------------------------------------------
// CONFIGURE THE KUBERNETES PROVIDER FOR EACH CLUSTER
//------------------------------------------------------------------------------
provider "kubernetes" {
  alias                  = "cluster01"
  host                   = run.setup_clusters.cluster01_kubeconfig.host
  client_certificate     = base64decode(run.setup_clusters.cluster01_kubeconfig.client_certificate)
  client_key             = base64decode(run.setup_clusters.cluster01_kubeconfig.client_key)
  cluster_ca_certificate = base64decode(run.setup_clusters.cluster01_kubeconfig.cluster_ca_certificate)
}

provider "kubernetes" {
  alias                  = "cluster02"
  host                   = run.setup_clusters.cluster02_kubeconfig.host
  client_certificate     = base64decode(run.setup_clusters.cluster02_kubeconfig.client_certificate)
  client_key             = base64decode(run.setup_clusters.cluster02_kubeconfig.client_key)
  cluster_ca_certificate = base64decode(run.setup_clusters.cluster02_kubeconfig.cluster_ca_certificate)
}

//------------------------------------------------------------------------------
// DEPLOY TWO SAMPLE APPLICATIONS USING A HELPER MODULE
//------------------------------------------------------------------------------
run "setup_applications" {
  providers = {
    kubernetes.cluster01 = kubernetes.cluster01
    kubernetes.cluster02 = kubernetes.cluster02
  }

  module {
    source = "./helper/apps"
  }
}

//------------------------------------------------------------------------------
// READ THE APPLICATION SERVICE'S IP ADDRESS'
//------------------------------------------------------------------------------
run "query_service_ips" {
  providers = {
    kubernetes.cluster01 = kubernetes.cluster01
    kubernetes.cluster02 = kubernetes.cluster02
  }

  module {
    source = "./helper/service-ip"
  }
}

//------------------------------------------------------------------------------
// SET UP TRAFFIC MANAGER
//------------------------------------------------------------------------------
run "set_up_traffic_manager" {
  variables {
    resource_group = run.setup_resource_group.resource_group
    endpoints = [
      {
        name     = "cluster01"
        target   = run.query_service_ips.service01_ip
        priority = 100
        enabled  = true
      },
      {
        name     = "cluster02"
        target   = run.query_service_ips.service02_ip
        priority = 200
        enabled  = false
      }
    ]
  }

  module {
    source  = "app.terraform.io/mattias-fjellstrom/traffic-manager-module/hashitalks"
    version = "1.0.0"
  }
}

//------------------------------------------------------------------------------
// TEST THAT APP01 IS REACHABLE FROM THE INTERNET
//------------------------------------------------------------------------------
run "poll_traffic_manager_app01" {
  variables {
    fqdn    = run.set_up_traffic_manager.traffic_manager_profile.fqdn
    trigger = "test-app-01"
  }

  module {
    source = "./helper/http"
  }

  assert {
    condition     = data.http.tm.status_code == 200
    error_message = "Invalid response code from app01: ${data.http.tm.status_code}"
  }

  assert {
    condition     = strcontains(data.http.tm.response_body, "Hello HashiTalks 2024 v1!")
    error_message = "Invalid response body from app01"
  }
}

//------------------------------------------------------------------------------
// RECONFIGURE TRAFFIC MANAGER
//------------------------------------------------------------------------------
run "update_traffic_manager_endpoints" {
  variables {
    resource_group = run.setup_resource_group.resource_group
    endpoints = [
      {
        name     = "cluster01"
        target   = run.query_service_ips.service01_ip
        priority = 100
        enabled  = false
      },
      {
        name     = "cluster02"
        target   = run.query_service_ips.service02_ip
        priority = 200
        enabled  = true
      }
    ]
  }

  module {
    source  = "app.terraform.io/mattias-fjellstrom/traffic-manager-module/hashitalks"
    version = "1.0.0"
  }
}

//------------------------------------------------------------------------------
// TEST THAT APP02 IS REACHABLE FROM THE INTERNET
//------------------------------------------------------------------------------
run "poll_traffic_manager_app02" {
  variables {
    fqdn    = run.set_up_traffic_manager.traffic_manager_profile.fqdn
    trigger = "test-app-02"
  }

  module {
    source = "./helper/http"
  }

  assert {
    condition     = data.http.tm.status_code == 200
    error_message = "Invalid response code from app02: ${data.http.tm.status_code}"
  }

  assert {
    condition     = strcontains(data.http.tm.response_body, "Hello HashiTalks 2024 v2!")
    error_message = "Invalid response body from app02"
  }
}