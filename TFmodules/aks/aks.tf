# Creates cluster with default linux node pool

resource "azurerm_kubernetes_cluster" "akscluster" {
  name                = var.prefix
  dns_prefix          = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name

  default_node_pool {
    name            = "agentpool"
    vm_size         = "Standard_DS2_v2"
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"
    node_count = 2
    vnet_subnet_id = var.vnet_subnet_id
  }

  linux_profile {
    admin_username = "sysadmin"

    ssh_key {
      key_data = file(var.public_ssh_key_path)
    }

  }

  service_principal {
    client_id     = var.kubernetes_client_id
    client_secret = var.kubernetes_client_secret
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "192.168.100.10"
    service_cidr = "192.168.100.0/24"
    docker_bridge_cidr = "172.17.0.1/16"

  }

  windows_profile {
    admin_username = "sysadmin"
    admin_password = "P@ssw0rd12345!!"
    
    }
}

# Created additional Windows Node pool

resource "azurerm_kubernetes_cluster_node_pool" "windows" {
  name                  = "wincon"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.akscluster.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  os_type               = "Windows" #capitalization matters
  vnet_subnet_id        = var.vnet_subnet_id


}