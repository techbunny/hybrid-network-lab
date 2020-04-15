# Creates a VNET with one default Subnet


resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.address_space] 
  tags                = var.tags

}

resource "azurerm_subnet" "vnet" {
  name                 = "default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefix       = var.default_subnet_prefix

  depends_on = [azurerm_virtual_network.vnet]
# }
}



# data "azurerm_virtual_network" "vnet" {
#   name                = var.vnet_name
#   resource_group_name = var.resource_group_name

#   depends_on = [azurerm_virtual_network.vnet]
# }

# data "azurerm_subnet" "vnet" {
#   name                 = "default"
#   virtual_network_name = var.vnet_name
#   resource_group_name  = var.resource_group_name

#   depends_on = [azurerm_virtual_network.vnet]
# }






