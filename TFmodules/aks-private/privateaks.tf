module "akssubnet" {
  source = "../networking/subnet"

  resource_group_name = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  subnet_prefix = "10.1.2.0/24"
  subnet_name = "aks"
}

resource "azurerm_kubernetes_cluster" "private" {
  name                = "${var.prefix}-k8s"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.prefix}-k8s"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
    enable_auto_scaling = true
    min_count = 1
    max_count = 3    
    type = "VirtualMachineScaleSets"
    vnet_subnet_id = module.akssubnet.subnet_id
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }

  identity {
    type = "SystemAssigned"
  }

  windows_profile {
    admin_username = "sysadmin"
    admin_password = "P@ssw0rd12345!!"
  }

  private_cluster_enabled = true




}