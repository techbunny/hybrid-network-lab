# "Cloud" Resources

resource "azurerm_resource_group" "cloud" {
  name     = "${var.rg_name_cloud}"
  location = "${var.location_cloud}"
  tags     = "${var.tags}"     
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "${var.vnet1_name}"
  resource_group_name = "${azurerm_resource_group.cloud.name}"
  location            = "${azurerm_resource_group.cloud.location}"
  address_space       = ["${var.address_space1}"] 
  tags                = "${var.tags}"
}

resource "azurerm_subnet" "vnet1_default" {
  name                 = "default"
  resource_group_name  = "${azurerm_resource_group.cloud.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet1.name}"
  address_prefix       = "172.21.1.0/24"
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "${var.vnet2_name}"
  resource_group_name = "${azurerm_resource_group.cloud.name}"
  location            = "${azurerm_resource_group.cloud.location}"
  address_space       = ["${var.address_space2}"] 
  tags                = "${var.tags}"
}

resource "azurerm_subnet" "vnet2_default" {
  name                 = "default"
  resource_group_name  = "${azurerm_resource_group.cloud.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet2.name}"
  address_prefix       = "172.22.1.0/24"
}

resource "azurerm_subnet" "vnet2_gw" {
  name                 = "GatewaySubnet"
  resource_group_name  = "${azurerm_resource_group.cloud.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet2.name}"
  address_prefix       = "172.22.250.0/24"  
}

# Fake "On Prem" Resources

resource "azurerm_resource_group" "fakeonprem" {
  name     = "${var.rg_name_fakeonprem}"
  location = "${var.location_fakeonprem}"
  tags     = "${var.tags}"     
}

resource "azurerm_virtual_network" "vnet3" {
  name                = "${var.vnet3_name}"
  resource_group_name = "${azurerm_resource_group.fakeonprem.name}"
  location            = "${azurerm_resource_group.fakeonprem.location}"
  address_space       = ["${var.address_space3}"] 
  tags                = "${var.tags}"
}

resource "azurerm_subnet" "vnet3_default" {
  name                 = "default"
  resource_group_name  = "${azurerm_resource_group.fakeonprem.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet3.name}"
  address_prefix       = "172.30.1.0/24"
}

resource "azurerm_subnet" "vnet3_gw" {
  name                 = "GatewaySubnet"
  resource_group_name  = "${azurerm_resource_group.fakeonprem.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet3.name}"
  address_prefix       = "172.30.250.0/24"  
}

# Public IP Addresses for VPN Gateways

resource "azurerm_public_ip" "gwip2" {
  name                = "gwip2"
  location            = "${azurerm_resource_group.cloud.location}"
  resource_group_name = "${azurerm_resource_group.cloud.name}"

  allocation_method = "Dynamic"
  depends_on = [azurerm_subnet.vnet2_gw]
}

resource "azurerm_public_ip" "gwip3" {
  name                = "gwip3"
  location            = "${azurerm_resource_group.fakeonprem.location}"
  resource_group_name = "${azurerm_resource_group.fakeonprem.name}"

  allocation_method = "Dynamic"
  depends_on = [azurerm_subnet.vnet3_gw]
}


