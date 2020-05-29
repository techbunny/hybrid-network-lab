data "azurerm_automation_account" "dsc" {
  name                = "dscautomation"
  resource_group_name = "${var.region1_name}_core"
}

data "azurerm_log_analytics_workspace" "core" {
  name = "${var.region1_name}-workspace"
  resource_group_name = "${var.region1_name}_core"
}

# Collect data from CoreInfra deployment for Region 1 DCs

data "azurerm_virtual_network" "region_core" {
  name                = "${var.region1_name}_vnet"
  resource_group_name = "${var.region1_name}_core"
}

data "azurerm_subnet" "region_core" {
  name                 = "default"
  resource_group_name  = data.azurerm_virtual_network.region_core.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.region_core.name
}

data "azurerm_lb" "lb" {
  name                = "lb-outbound-only"
  resource_group_name = "${var.region1_name}_core"
}

data "azurerm_lb_backend_address_pool" "lb" {
  name            = "${data.azurerm_virtual_network.region_core.resource_group_name}-outbound-pool"
  loadbalancer_id = data.azurerm_lb.lb.id
}

# Create AV Set for DCs (Both Regions)

resource "azurerm_availability_set" "compute" {
  name                         = "dc-${var.region1_name}-avset"
  resource_group_name          = data.azurerm_virtual_network.region_core.resource_group_name
  location                     = data.azurerm_virtual_network.region_core.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = var.tags
}

resource "azurerm_availability_set" "compute2" {
  name                         = "dc-${var.region2_name}-avset"
  resource_group_name          = data.azurerm_virtual_network.region2_core.resource_group_name
  location                     = data.azurerm_virtual_network.region2_core.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = var.tags
}


# Deploy VM for DC (Region 1)

module "create_dc1_region1" {
  source = "../../../TFmodules/avset_compute_dc"

  resource_group_name = data.azurerm_virtual_network.region_core.resource_group_name
  location            = data.azurerm_virtual_network.region_core.location
  vnet_subnet_id      = data.azurerm_subnet.region_core.id
  avset_id            = azurerm_availability_set.compute.id


  tags                    = var.tags
  compute_hostname_prefix = "DC-01-${var.region1_name}"

  vm_size                        = "Standard_D2_v2"
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
  static_ip_address              = "10.1.1.200"
  outbound_backendpool_id        = data.azurerm_lb_backend_address_pool.lb.id
  dsc_config                     = "DC1config.localhost"
  dsc_key                        = data.azurerm_automation_account.dsc.primary_key
  dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint
  workspace_id  = data.azurerm_log_analytics_workspace.core.workspace_id             
  workspace_key = data.azurerm_log_analytics_workspace.core.primary_shared_key


}


module "create_dc2_region1" {
  source = "../../../TFmodules/avset_compute_dc"

  resource_group_name = data.azurerm_virtual_network.region_core.resource_group_name
  location            = data.azurerm_virtual_network.region_core.location
  vnet_subnet_id      = data.azurerm_subnet.region_core.id
  avset_id            = azurerm_availability_set.compute.id

  tags                    = var.tags
  compute_hostname_prefix = "DC-02-${var.region1_name}"

  vm_size                        = "Standard_D2_v2"
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
  static_ip_address              = "10.1.1.201"
  outbound_backendpool_id        = data.azurerm_lb_backend_address_pool.lb.id
  dsc_config                     = "DC2config.localhost"
  dsc_key                        = data.azurerm_automation_account.dsc.primary_key
  dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint
  workspace_id  = data.azurerm_log_analytics_workspace.core.workspace_id             
  workspace_key = data.azurerm_log_analytics_workspace.core.primary_shared_key

}


# Deploy VMs for DCs (Region 2)

data "azurerm_virtual_network" "region2_core" {
  name                = "${var.region2_name}_vnet"
  resource_group_name = "${var.region2_name}_core"
}

data "azurerm_subnet" "region2_core" {
  name                 = "default"
  resource_group_name  = data.azurerm_virtual_network.region2_core.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.region2_core.name
}

data "azurerm_lb" "lb2" {
  name                = "lb2-outbound-only"
  resource_group_name = "${var.region2_name}_core"
}

data "azurerm_lb_backend_address_pool" "lb2" {
  name            = "${data.azurerm_virtual_network.region2_core.resource_group_name}-outbound-pool"
  loadbalancer_id = data.azurerm_lb.lb2.id
}

module "create_dc3_region2" {
  source = "../../../TFmodules/avset_compute_dc"

  resource_group_name = data.azurerm_virtual_network.region2_core.resource_group_name
  location            = data.azurerm_virtual_network.region2_core.location
  vnet_subnet_id      = data.azurerm_subnet.region2_core.id
  avset_id            = azurerm_availability_set.compute2.id

  tags                    = var.tags
  compute_hostname_prefix = "DC-05-${var.region2_name}"

  vm_size                        = "Standard_D2_v2"
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
  static_ip_address              = "10.2.1.200"
  outbound_backendpool_id        = data.azurerm_lb_backend_address_pool.lb2.id
  dsc_config                     = "DC2config.localhost"
  dsc_key                        = data.azurerm_automation_account.dsc.primary_key
  dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint
  workspace_id  = data.azurerm_log_analytics_workspace.core.workspace_id             
  workspace_key = data.azurerm_log_analytics_workspace.core.primary_shared_key

}




