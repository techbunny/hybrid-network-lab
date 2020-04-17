resource "azurerm_resource_group" "region1" {
  name     = var.region1_name
  location = var.region1
  tags     = var.tags     
}

resource "azurerm_resource_group" "region2" {
  name     = var.region2_name
  location = var.region2
  tags     = var.tags     
}

# Add Subnets to Core Networks in each Region

data "azurerm_virtual_network" "region1" {
  name                = "Region1_vnet"
  resource_group_name = "Region1_Core"
}

data "azurerm_virtual_network" "region2" {
  name                = "Region2_vnet"
  resource_group_name = "Region2_Core"
}

resource "azurerm_subnet" "R1_FrontEnd" {
  name                 = "frontend"
  resource_group_name  = data.azurerm_virtual_network.region1.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.region1.name
  address_prefix       = "10.1.2.0/24"
}

resource "azurerm_subnet" "R2_Frontend" {
  name                 = "frontend"
  resource_group_name  = data.azurerm_virtual_network.region2.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.region2.name
  address_prefix       = "10.2.2.0/24"
}

# Build a Web Server

module "web_server" {
  source = "../../../TFmodules/zonal_compute"

  resource_group_name          = azurerm_resource_group.region1.name
  location                     = azurerm_resource_group.region1.location
  vnet_subnet_id               = azurerm_subnet.R1_FrontEnd.id
    
  tags                           = var.tags
  compute_hostname_prefix        = "FE-region1"
  compute_instance_count         = 1

  vm_size                        = "Standard_D2_v2"
  zones                          = "1"
  os_publisher                   = var.os_publisher
  os_offer                       = var.os_offer
  os_sku                         = var.os_sku
  os_version                     = var.os_version
  storage_account_type           = var.storage_account_type
  compute_boot_volume_size_in_gb = var.compute_boot_volume_size_in_gb
  admin_username                 = var.admin_username
  admin_password                 = var.admin_password
  enable_accelerated_networking  = var.enable_accelerated_networking
  boot_diag_SA_endpoint          = var.boot_diag_SA_endpoint
  # create_public_ip               = 0
  # create_data_disk               = 1
  # assign_bepool                  = 0
  # create_av_set                  = 0

}





