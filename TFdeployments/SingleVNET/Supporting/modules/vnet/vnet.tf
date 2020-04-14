# Virtual Newtwork

resource "azurerm_virtual_network" "custom-vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.100.0.0/16"]
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.custom-vnet.name
  address_prefix       = "10.100.0.0/24"
}

resource "azurerm_subnet" "aks" {
  name                 = "aksSubnet"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.custom-vnet.name
  address_prefix       = "10.100.128.0/17"
}