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

data "azurerm_automation_account" "dsc" {
  name                = "dscautomation"
  resource_group_name = "${var.region_name}_core"
}

data "azurerm_log_analytics_workspace" "core" {
  name                = "region1workspace"
  resource_group_name = "${var.region_name}_core"
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
  source = "../../../TFmodules/zr_compute_dsc"

  resource_group_name = azurerm_resource_group.rg_web.name
  location            = azurerm_resource_group.rg_web.location
  vnet_subnet_id      = azurerm_subnet.webFE.id
  region_name         = var.region_name

  tags                    = var.tags
  compute_hostname_prefix = "web-${var.region_name}"
  compute_instance_count  = 2
  p30_instance_count      = 2

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
  assign_bepool                  = 1
  backendpool_id                 = module.web_lb.app_backendpool_id
  outbound_backendpool_id        = data.azurerm_lb_backend_address_pool.lb.id
  dsc_config                     = "IISInstall.localhost"
  dsc_key                        = data.azurerm_automation_account.dsc.primary_key
  dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint
  domain_name                    = "IMPERFECTLAB.COM"
  domain_user                    = "IMPERFECTLAB.COM\\sysadmin"
  workspace_id                   = data.azurerm_log_analytics_workspace.core.workspace_id
  workspace_key                  = data.azurerm_log_analytics_workspace.core.primary_shared_key

}

module "web_lb" {
  source = "../../../TFmodules/loadbalancer/lb_internal"

  lbname      = "web-lb-internal"
  location    = azurerm_resource_group.rg_web.location
  region_name = azurerm_resource_group.rg_web.name
  # zones                          = "1,2"
  subnetName              = azurerm_subnet.webFE.name
  core_region_name        = "${var.region_name}_core"
  core_vnet_name          = "${var.region_name}_vnet"
  compute_hostname_prefix = "web-${var.region_name}"


}

module "rules_probes" {
  source = "../../../TFmodules/loadbalancer/lb_rule"

  rg_name                 = azurerm_resource_group.rg_web.name
  lb_id                   = module.web_lb.loadbalancer_id
  frontend_name           = module.web_lb.frontend_name
  backend_address_pool_id = module.web_lb.app_backendpool_id


}

# Build App Servers

module "app_server" {
  source = "../../../TFmodules/zr_compute_dsc"

  resource_group_name = azurerm_resource_group.rg_app.name
  location            = azurerm_resource_group.rg_app.location
  vnet_subnet_id      = azurerm_subnet.appFE.id
  region_name         = var.region_name

  tags                           = var.tags
  compute_hostname_prefix        = "app-${var.region_name}"
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
  assign_bepool                  = 1
  backendpool_id                 = module.app_lb.app_backendpool_id
  outbound_backendpool_id        = data.azurerm_lb_backend_address_pool.lb.id
  dsc_config                     = "DiskAttach.localhost"
  dsc_key                        = data.azurerm_automation_account.dsc.primary_key
  dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint
  domain_name                    = "IMPERFECTLAB.COM"
  domain_user                    = "IMPERFECTLAB.COM\\sysadmin"
  workspace_id                   = data.azurerm_log_analytics_workspace.core.workspace_id
  workspace_key                  = data.azurerm_log_analytics_workspace.core.primary_shared_key


}

# Create LB for App VMs

module "app_lb" {
  source = "../../../TFmodules/loadbalancer/lb_internal"

  lbname      = "app-lb-internal"
  location    = azurerm_resource_group.rg_app.location
  region_name = azurerm_resource_group.rg_app.name
  subnetName              = azurerm_subnet.appFE.name
  core_vnet_name          = "${var.region_name}_vnet"
  core_region_name        = "${var.region_name}_core"
  compute_hostname_prefix = "app-${var.region_name}"


}

data "azurerm_lb" "lb" {
  name                = "lb-outbound-only"
  resource_group_name = data.azurerm_virtual_network.region_core.resource_group_name
}

data "azurerm_lb_backend_address_pool" "lb" {
  name            = "${data.azurerm_virtual_network.region_core.resource_group_name}-outbound-pool"
  loadbalancer_id = data.azurerm_lb.lb.id
}

## Example VMSS Module

module "vmss_web_server" {
  source = "../../../TFmodules/zr_vmss_dsc"

  resource_group_name = azurerm_resource_group.rg_web.name
  location            = azurerm_resource_group.rg_web.location
  vnet_subnet_id      = azurerm_subnet.webFE.id
  region_name         = var.region_name

  tags                    = var.tags
  compute_hostname_prefix = "web-${var.region_name}"
  compute_instance_count  = 2
  p30_instance_count      = 2

  vm_size                        = "Standard_DS3_v2"
  vmss_name                      = "web2"
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
  backendpool_id                 = module.web_lb.app_backendpool_id
  outbound_backendpool_id        = data.azurerm_lb_backend_address_pool.lb.id
  health_probe_id                = module.rules_probes.probe_id
  dsc_config                     = "IISInstall.localhost"
  dsc_key                        = data.azurerm_automation_account.dsc.primary_key
  dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint
  domain_name                    = "IMPERFECTLAB.COM"
  domain_user                    = "IMPERFECTLAB.COM\\sysadmin"
  # workspace_id                   = data.azurerm_log_analytics_workspace.core.workspace_id
  # workspace_key                  = data.azurerm_log_analytics_workspace.core.primary_shared_key


}





