resource "azurerm_resource_group" "bluegreen" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags     
}

# Deploy VNETS with Subnets

module "vnet1" {
  source = "../../TFmodules/networking/vnet"

  resource_group_name = azurerm_resource_group.bluegreen.name
  location            = azurerm_resource_group.bluegreen.location

  vnet_name          = "vnet"
  address_space     = "10.0.0.0/16"
  default_subnet_prefix = "10.0.0.0/24"

}


