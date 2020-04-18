resource "azurerm_resource_group" "region" {
  name     = var.region_name
  location = var.region
  tags     = var.tags     
}

data "azurerm_proximity_placement_group" "region_ppg" {
  name                = var.region_ppg
  resource_group_name = var.core_region_name
}


# Add Subnets to Core Networks in each Region

data "azurerm_virtual_network" "region" {
  name                = "Region1_vnet"
  resource_group_name = "EastUS_Core"
}

resource "azurerm_subnet" "webFE" {
  name                 = "web-subnet"
  resource_group_name  = data.azurerm_virtual_network.region.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.region.name
  address_prefix       = "10.1.4.0/24"
}

resource "azurerm_subnet" "appFE" {
  name                 = "app-subnet"
  resource_group_name  = data.azurerm_virtual_network.region.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.region.name
  address_prefix       = "10.1.3.0/24"
}



# Build Web Servers

module "web_server" {
  source = "../../../TFmodules/zonal_compute"

  resource_group_name          = azurerm_resource_group.region.name
  location                     = azurerm_resource_group.region.location
  vnet_subnet_id               = azurerm_subnet.webFE.id
  region_ppg_id                = data.azurerm_proximity_placement_group.region_ppg.id
 # core_region_name             = var.core_region_name

    
  tags                           = var.tags
  compute_hostname_prefix        = "web-region1"
  compute_instance_count         = 2
  p30_instance_count             = 2

  vm_size                        = "Standard_DS11_v2"
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


# Build App Servers

module "app_server" {
  source = "../../../TFmodules/zonal_compute"

  resource_group_name          = azurerm_resource_group.region.name
  location                     = azurerm_resource_group.region.location
  vnet_subnet_id               = azurerm_subnet.appFE.id
  region_ppg_id                = data.azurerm_proximity_placement_group.region_ppg.id
  # core_region_name             = var.core_region_name

    
  tags                           = var.tags
  compute_hostname_prefix        = "app-region1"
  compute_instance_count         = 2
  p30_instance_count             = 2 

  vm_size                        = "Standard_DS11_v2"
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



