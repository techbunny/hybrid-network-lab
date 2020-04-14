# Data From Existing Infrastructure

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "aks" {
  name                 = "aksSubnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
}

data "azurerm_dns_zone" "public" {
  name                = var.dns_zone
  resource_group_name = var.resource_group_name
}
 
# AKS Cluster

resource "random_integer" "deployment" {
  min = 10000
  max = 99999
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${random_integer.deployment.result}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks${random_integer.deployment.result}"


  default_node_pool {
    name            = "agentpool"
    vm_size         = "Standard_DS2_v2"
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"
    vnet_subnet_id = data.azurerm_subnet.aks.id
    enable_auto_scaling = true
    max_count = 5
    min_count = 2
    node_count = 2
  }

  service_principal {
    client_id     = var.kubernetes_client_id
    client_secret = var.kubernetes_client_secret
  }

  network_profile {
      network_plugin = "kubenet"
      network_policy = "calico"
      service_cidr = "10.200.0.0/16"
      dns_service_ip = "10.200.0.10"    
      docker_bridge_cidr = "172.17.0.1/16"
      pod_cidr = "10.244.0.0/16"
  }

  tags = {
    Environment = "Testing"
  }

}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

# AKS DNS Record
resource "azurerm_dns_a_record" "helloworld_ingress" {
  name                = "helloworld"
  zone_name           = data.azurerm_dns_zone.public.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = ["10.100.200.1"]  #IP address of Internal Ingress
}
