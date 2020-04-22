resource "azurerm_resource_group" "rg_data" {
  name     = "${var.region_name}_data"
  location = var.region_loc
  tags     = var.tags    
}

# data "azurerm_proximity_placement_group" "region_ppg" {
#   name                = "${var.region_name}_ppg"
#   resource_group_name = "${var.region_name}_core"
#   }


# Add Subnets to Core Networks in each Region

data "azurerm_virtual_network" "region_core" {
  name                = "${var.region_name}_vnet"
  resource_group_name = "${var.region_name}_core"
}

resource "azurerm_subnet" "dataBE" {
  name                 = "data-subnet"
  resource_group_name  = data.azurerm_virtual_network.region_core.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.region_core.name
  address_prefix       = "10.1.6.0/24"
}


# Build SQL Servers

module "sql_server" {
  source = "../../../TFmodules/zr_compute"

  resource_group_name          = azurerm_resource_group.rg_data.name
  location                     = azurerm_resource_group.rg_data.location
  vnet_subnet_id               = azurerm_subnet.dataBE.id
  region_name                  = var.region_name
    
  tags                           = var.tags
  compute_hostname_prefix        = "sql-${var.region_name}"
  compute_instance_count         = 2
  p30_instance_count             = 10

  vm_size                        = "Standard_DS3_v2"
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
  assign_bepool                    = 0
  backendpool_id                   = null
  # create_av_set                  = 0

}




