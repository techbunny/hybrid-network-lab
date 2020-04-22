resource "azurerm_resource_group" "rg_web" {
  name     = "${var.region_name}_web"
  location = var.region_loc
  tags     = var.tags     
}

resource "azurerm_resource_group" "rg_app" {
  name     = "${var.region_name}_app"
  location = var.region_loc
  tags     = var.tags     
}

# Add Subnets to Core Networks in each Region

data "azurerm_virtual_network" "region_core" {
  name                = "${var.region_name}_vnet"
  resource_group_name = "${var.region_name}_core"
}

resource "azurerm_subnet" "webFE" {
  name                 = "web-subnet"
  resource_group_name  = data.azurerm_virtual_network.region_core.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.region_core.name
  address_prefix       = "10.1.4.0/24"
}

resource "azurerm_subnet" "appFE" {
  name                 = "app-subnet"
  resource_group_name  = data.azurerm_virtual_network.region_core.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.region_core.name
  address_prefix       = "10.1.3.0/24"
}


# Build Web Servers

module "web_server" {
  source = "../../../TFmodules/zr_compute"

  resource_group_name          = azurerm_resource_group.rg_web.name
  location                     = azurerm_resource_group.rg_web.location
  vnet_subnet_id               = azurerm_subnet.webFE.id
  region_name                  = var.region_name
    
  tags                           = var.tags
  compute_hostname_prefix        = "web-${var.region_name}"
  compute_instance_count         = 2
  p30_instance_count             = 2
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
  assign_bepool                    = 1
  backendpool_id                   = module.web_lb.app_backendpool_id

}

module "web_lb" {
  source = "../../../TFmodules/loadbalancer"

  lbname                         = "web-lb-internal"
  location                       = azurerm_resource_group.rg_web.location
  region_name                    = azurerm_resource_group.rg_web.name
  # zones                          = "1,2"
  subnetName                     = azurerm_subnet.webFE.name
  core_region_name               = "${var.region_name}_core"
  core_vnet_name                 = "${var.region_name}_vnet"
  compute_hostname_prefix        = "web-${var.region_name}"


}



# Build App Servers

# module "app_server" {
#   source = "../../../TFmodules/zr_compute"

#   resource_group_name          = azurerm_resource_group.rg_app.name
#   location                     = azurerm_resource_group.rg_app.location
#   vnet_subnet_id               = azurerm_subnet.appFE.id
#   region_name                  = var.region_name
    
#   tags                           = var.tags
#   compute_hostname_prefix        = "app-${var.region_name}"
#   compute_instance_count         = 2
#   p30_instance_count             = 2 
#   zones                        = "1"

#   vm_size                        = "Standard_DS3_v2"
#   os_publisher                   = var.os_publisher
#   os_offer                       = var.os_offer
#   os_sku                         = var.os_sku
#   os_version                     = var.os_version
#   storage_account_type           = var.storage_account_type
#   compute_boot_volume_size_in_gb = var.compute_boot_volume_size_in_gb
#   admin_username                 = var.admin_username
#   admin_password                 = var.admin_password
#   enable_accelerated_networking  = var.enable_accelerated_networking
#   boot_diag_SA_endpoint          = var.boot_diag_SA_endpoint
#   # create_public_ip               = 0
#   # create_data_disk               = 1
#   assign_bepool                    = 1
#   backendpool_id                   = module.app_lb.app_backendpool_id
#   # create_av_set                  = 0

# }


# Create LB for App VMs

# module "app_lb" {
#   source = "../../../TFmodules/loadbalancer"

#   lbname                         = "app-lb-internal"
#   location                       = azurerm_resource_group.rg_app.location
#   region_name                    = azurerm_resource_group.rg_app.name
#   # zones                          = "1,2"
#   subnetName                     = azurerm_subnet.appFE.name
#   core_vnet_name                  = "${var.region_name}_vnet"
#   core_region_name               = "${var.region_name}_core"
#   compute_hostname_prefix        = "app-${var.region_name}"


# }





