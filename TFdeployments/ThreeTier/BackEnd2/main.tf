# Create RGs for Data VMs

resource "azurerm_resource_group" "rg_data" {
  name     = "${var.region_name}_data"
  location = var.region_loc
  tags     = var.tags    
}


# Lookup DSC and Workspaces

data "azurerm_automation_account" "dsc" {
  name                = "dscautomation"
  resource_group_name = "${var.region1_name}_core"
}

data "azurerm_log_analytics_workspace" "core" {
  name = "${var.region1_name}-workspace"
  resource_group_name = "${var.region1_name}_core"
}


# Add Subnets to Core Networks in each Region

data "azurerm_virtual_network" "region_core" {
  name                = "${var.region_name}_vnet"
  resource_group_name = "${var.region_name}_core"
}

resource "azurerm_subnet" "dataBE" {
  name                 = "data-subnet"
  resource_group_name  = data.azurerm_virtual_network.region_core.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.region_core.name
  address_prefix       = "10.2.6.0/24"
}


# Create LB for App VMs

data "azurerm_lb" "lb" {
  name                = "lb2-outbound-only"
  resource_group_name = data.azurerm_virtual_network.region_core.resource_group_name
}

data "azurerm_lb_backend_address_pool" "lb" {
  name            = "${data.azurerm_virtual_network.region_core.resource_group_name}-outbound-pool"
  loadbalancer_id = data.azurerm_lb.lb.id
}

module "sql_lb" {
  source = "../../../TFmodules/loadbalancer/lb_internal"

  lbname      = "sql-lb-internal"
  location    = azurerm_resource_group.rg_data.location
  region_name = azurerm_resource_group.rg_data.name
  subnetName              = azurerm_subnet.dataBE.name
  core_vnet_name          = data.azurerm_virtual_network.region_core.name
  core_region_name        = data.azurerm_virtual_network.region_core.resource_group_name
  compute_hostname_prefix = "app-${var.region_name}"


}



# Build SQL Servers

module "sql_server" {
  source = "../../../TFmodules/zr_compute_dsc"

  resource_group_name          = azurerm_resource_group.rg_data.name
  location                     = azurerm_resource_group.rg_data.location
  vnet_subnet_id               = azurerm_subnet.dataBE.id
  region_name                  = var.region_name
    
  tags                           = var.tags
  compute_hostname_prefix        = "sql-${var.region_name}"
  compute_instance_count         = 6
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
  backendpool_id                 = module.sql_lb.app_backendpool_id
  outbound_backendpool_id        = data.azurerm_lb_backend_address_pool.lb.id
  dsc_config                     = "DiskAttach.localhost"
  dsc_key                        = data.azurerm_automation_account.dsc.primary_key
  dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint
  domain_name                    = "IMPERFECTLAB.COM"
  domain_user                    = "IMPERFECTLAB.COM\\sysadmin"
  workspace_id                   = data.azurerm_log_analytics_workspace.core.workspace_id
  workspace_key                  = data.azurerm_log_analytics_workspace.core.primary_shared_key

}




