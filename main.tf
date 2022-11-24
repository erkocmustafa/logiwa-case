terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "logiwa" {
  name     = "example-resources"
  location = "westeurope"
}

resource "azurerm_kubernetes_cluster" "logiwa" {
  name                = "example-aks1"
  location            = azurerm_resource_group.logiwa.location
  resource_group_name = azurerm_resource_group.logiwa.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "logiwa"
    node_count = 2
    vm_size    = "Standard_D2_v2"
  }
  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
  }
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "calico"
  }
  service_principal {
    client_id     = "***************************************"
    client_secret = "***************************************"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "logiwa" {
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.logiwa.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 2

  tags = {
    Environment = "Production"
  }
}
