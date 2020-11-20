resource "azurerm_resource_group" "bluegreen" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

# Deploy VNETS with Subnets

module "vnet" {
  source = "../../TFmodules/networking/vnet"

  resource_group_name = azurerm_resource_group.bluegreen.name
  location            = azurerm_resource_group.bluegreen.location

  vnet_name             = "vnet"
  address_space         = "10.0.0.0/16"
  default_subnet_prefix = "10.0.0.0/24"
  dns_servers = [
    "168.63.129.16"
  ]

}
resource "azurerm_subnet" "blue" {
  name                 = "blue-subnet"
  resource_group_name  = azurerm_resource_group.bluegreen.name
  virtual_network_name = module.vnet.vnet_name
  address_prefix       = "10.0.10.0/24"
}

resource "azurerm_subnet" "green" {
  name                 = "green-subnet"
  resource_group_name  = azurerm_resource_group.bluegreen.name
  virtual_network_name = module.vnet.vnet_name
  address_prefix       = "10.0.11.0/24"
}

 # Load Balancers

module "lb_bluegreen" {
  source = "../../TFmodules/loadbalancer/lb_external"

  lbname   = "lb-bluegreen"
  rg_name = azurerm_resource_group.bluegreen.name
  location            = azurerm_resource_group.bluegreen.location
  subnetName              = module.vnet.default_subnet_name
  core_vnet_name          = module.vnet.vnet_name
  core_rg_name            = azurerm_resource_group.bluegreen.name
  compute_hostname_prefix = "bluegreen-outbound"


}

module "blue_lb" {
  source = "../../TFmodules/loadbalancer/lb_internal"

  lbname      = "blue-lb-internal"
  region_name = azurerm_resource_group.bluegreen.name
  location            = azurerm_resource_group.bluegreen.location
  subnetName              = azurerm_subnet.blue.name
  core_region_name        = azurerm_resource_group.bluegreen.name
  core_vnet_name          = module.vnet.vnet_name
  compute_hostname_prefix = "blue"


}

module "rules_probes_blue" {
  source = "../../TFmodules/loadbalancer/lb_rule"

  rg_name                 = azurerm_resource_group.bluegreen.name
  lb_id                   = module.blue_lb.loadbalancer_id
  frontend_name           = module.blue_lb.frontend_name
  backend_address_pool_id = module.blue_lb.app_backendpool_id
    http-LBRule = "http-LBRule"
  http-probe = "http-probe"


}

module "green_lb" {
  source = "../../TFmodules/loadbalancer/lb_internal"

  lbname      = "green-lb-internal"
  region_name = azurerm_resource_group.bluegreen.name
  location            = azurerm_resource_group.bluegreen.location
  subnetName              = azurerm_subnet.green.name
  core_region_name        = azurerm_resource_group.bluegreen.name
  core_vnet_name          = module.vnet.vnet_name
  compute_hostname_prefix = "green"


}

module "rules_probes_green" {
  source = "../../TFmodules/loadbalancer/lb_rule"

  rg_name                 = azurerm_resource_group.bluegreen.name
  lb_id                   = module.green_lb.loadbalancer_id
  frontend_name           = module.green_lb.frontend_name
  backend_address_pool_id = module.green_lb.app_backendpool_id
  http-LBRule = "http-LBRule"
  http-probe = "http-probe"


}

module "AppGW" {
  source = "../../TFmodules/appgw"

  resource_group_name  = azurerm_resource_group.bluegreen.name
  location = azurerm_resource_group.bluegreen.location
  appgw_name = "jkc-greenbluegw"
  vnet_name = module.vnet.vnet_name
  #ip_addresses = "10.0.10.4"
  ip_addresses = "10.0.11.4"
  # ip_addresses = "10.0.10.4", "10.0.11.4"

  }

# Deploy DSC Service

module "DSC_setup" {
  source = "../../TFmodules/dsc_setup"

  rg_name  = azurerm_resource_group.bluegreen.name
  location = azurerm_resource_group.bluegreen.location

}

module "DSC_config" {
  source = "./dsc_configuration"

  rg_name  = azurerm_resource_group.bluegreen.name
  location = azurerm_resource_group.bluegreen.location

}

## Blue VMSS Module

module "vmss_blue_server" {
  source = "../../TFmodules/zr_vmss_dsc_nodomain"

  resource_group_name = azurerm_resource_group.bluegreen.name
  location            = azurerm_resource_group.bluegreen.location
  vnet_subnet_id      = azurerm_subnet.blue.id
  region_name         = var.rg_name

  tags                    = var.tags
  compute_hostname_prefix = "blue"
  # compute_instance_count  = 2
  p30_instance_count      = 0

  vm_size                        = "Standard_DS3_v2"
  vmss_name                      = "blue"
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
  assign_bepool                  = 1
  backendpool_id                 = module.blue_lb.app_backendpool_id
  outbound_backendpool_id        = module.lb_bluegreen.vm_backendpool_id
  health_probe_id                = module.rules_probes_blue.probe_id
  dsc_config                     = "Blue.localhost"
  dsc_key                        = module.DSC_setup.dsc_key
  dsc_endpoint                   = module.DSC_setup.dsc_endpoint
}


# Green VMSS Module

module "vmss_green_server" {
  source = "../../TFmodules/zr_vmss_dsc_nodomain"

  resource_group_name = azurerm_resource_group.bluegreen.name
  location            = azurerm_resource_group.bluegreen.location
  vnet_subnet_id      = azurerm_subnet.green.id
  region_name         = var.rg_name

  tags                    = var.tags
  compute_hostname_prefix = "green"
  # compute_instance_count  = 2
  p30_instance_count      = 0

  vm_size                        = "Standard_DS3_v2"
  vmss_name                      = "green"
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
  assign_bepool                  = 1
  backendpool_id                 = module.green_lb.app_backendpool_id
  outbound_backendpool_id        = module.lb_bluegreen.vm_backendpool_id
  health_probe_id                = module.rules_probes_green.probe_id
  dsc_config                     = "Green.localhost"
  dsc_key                        = module.DSC_setup.dsc_key
  dsc_endpoint                   = module.DSC_setup.dsc_endpoint
  
}





