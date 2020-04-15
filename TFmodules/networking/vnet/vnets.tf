# Creates a VNET with one default Subnet


resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.address_space] 
  tags                = var.tags

  subnet {
    name           = "default"
    address_prefix = var.default_subnet_prefix
  }
}




