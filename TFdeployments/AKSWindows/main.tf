# Base Resources

resource "azurerm_resource_group" "resourcegroup" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}


# Private Network

module "vnet1" {
  source = "../../TFmodules/networking/vnet"

  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location

  vnet_name             = "vnetvnet"
  # ddos_plan_id          = azurerm_network_ddos_protection_plan.ddosprotection.id
  address_space         = "10.1.0.0/16"
  default_subnet_prefix = "10.1.1.0/24"
  dns_servers = [
    "168.63.129.16"
  ]

}

# AKS

module "privateaks" {
  source = "../../TFmodules/aks-private"

  prefix = "jkcaks"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location
  virtual_network_name = module.vnet1.vnet_name
}



# ACR