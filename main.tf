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
