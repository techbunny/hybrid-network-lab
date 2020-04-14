
# Hub

resource "azurerm_virtual_network" "vnet1" {
  name                = var.vnet1_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  address_space       = [var.address_space1] 
  tags                = "${var.tags}"
}

resource "azurerm_subnet" "vnet1_default" {
  name                 = "default"
  resource_group_name = var.resource_group_name
  virtual_network_name = "${azurerm_virtual_network.vnet1.name}"
  address_prefix       = "10.0.0.0/24"
}


# Spoke 1 - Prod

resource "azurerm_virtual_network" "vnet2" {
  name                = var.vnet2_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  address_space       = ["${var.address_space2}"] 
  tags                = "${var.tags}"
}

resource "azurerm_subnet" "vnet2_default" {
  name                 = "default"
  resource_group_name = var.resource_group_name
  virtual_network_name = "${azurerm_virtual_network.vnet2.name}"
  address_prefix       = "10.10.0.0/24"
}

resource "azurerm_subnet" "aks" {
  name                 = "aksSubnet"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.custom-vnet.name
  address_prefix       = "10.10.128.0/17"
}


# Spoke 2 - Staging

resource "azurerm_virtual_network" "vnet3" {
  name                = var.vnet3_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  address_space       = ["${var.address_space3}"] 
  tags                = "${var.tags}"
}

resource "azurerm_subnet" "vnet3_default" {
  name                 = "default"
  resource_group_name = var.resource_group_name
  virtual_network_name = "${azurerm_virtual_network.vnet3.name}"
  address_prefix       = "172.30.1.0/24"
}



