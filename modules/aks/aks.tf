# Create a subnet in the existing VNET

resource "azurerm_subnet" "akscluster" {
  name                 = "aks-subnet"
  resource_group_name  = var.resource_group_name
  address_prefix       = var.address_prefix
  virtual_network_name = var.vnet_network_name

  # this field is deprecated and will be removed in 2.0 - but is required until then
  route_table_id = azurerm_route_table.akscluster.id
}

# Create all AKS specific resources in a different RG

resource "azurerm_resource_group" "akscluster" {
  name     = "${var.prefix}-aks-resources"
  location = var.location
}

resource "azurerm_route_table" "akscluster" {
  name                = "${var.prefix}-routetable"
  location            = var.location
  resource_group_name = azurerm_resource_group.akscluster.name

  route {
    name                   = "default"
    address_prefix         = "10.100.0.0/14"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.1"
  }
}

resource "azurerm_subnet_route_table_association" "akscluster" {
  subnet_id      = azurerm_subnet.akscluster.id
  route_table_id = azurerm_route_table.akscluster.id
}

resource "azurerm_kubernetes_cluster" "akscluster" {
  name                = var.prefix
  dns_prefix          = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.akscluster.name

  default_node_pool {
    name            = "agentpool"
    vm_size         = "Standard_DS2_v2"
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"
    node_count = 2

    # Required for advanced networking
    vnet_subnet_id = azurerm_subnet.akscluster.id
  }

  linux_profile {
    admin_username = "sysadmin"

    ssh_key {
      key_data = "${file(var.public_ssh_key_path)}"
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
}