resource "azurerm_resource_group" "region" {
  name     = var.region1_name
  location = var.region1
  tags     = var.tags     
}

# Add Subnets to Core Network

data "azurerm_virtual_network" "region" {
  name                = "Region1_vnet"
  resource_group_name = "Region1_Core"
}


resource "azurerm_subnet" "R1_Backend" {
  name                 = "backend"
  resource_group_name  = data.azurerm_virtual_network.region1.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.region1.name
  address_prefix       = "10.1.3.0/24"
}








