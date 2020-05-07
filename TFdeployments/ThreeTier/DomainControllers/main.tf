# Collect data from CoreInfra deployment

data "azurerm_virtual_network" "region_core" {
  name                = "${var.region1_name}_vnet"
  resource_group_name = "${var.region1_name}_core"
}

data "azurerm_subnet" "region_core" {
  name                 = "default"
  resource_group_name  = data.azurerm_virtual_network.region_core.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.region_core.name
}

data "azurerm_automation_account" "dsc" {
  name                = "dscautomation"
  resource_group_name = "${var.region1_name}_core"
}

data "azurerm_lb" "lb" {
  name                = "lb-outbound-only"
  resource_group_name  = "${var.region1_name}_core"
}

data "azurerm_lb_backend_address_pool" "lb" {
  name            = "${data.azurerm_virtual_network.region_core.resource_group_name}-outbound-pool"
  loadbalancer_id = data.azurerm_lb.lb.id
}

# Deploy VM for DC

module "create_dc1_region1" {
  source = "../../../TFmodules/avset_compute_dc"

  resource_group_name          = data.azurerm_virtual_network.region_core.resource_group_name
  location                     = data.azurerm_virtual_network.region_core.location
  vnet_subnet_id               = data.azurerm_subnet.region_core.id

  tags                           = var.tags
  compute_hostname_prefix        = "DC-${var.region1_name}"
  compute_instance_count         = 1

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
  create_data_disk               = 1
  assign_bepool                  = 1
  static_ip_address              = "10.1.1.200"
  outbound_backendpool_id        = data.azurerm_lb_backend_address_pool.lb.id
  dsc_config                     = "DC1config.localhost"
  dsc_key                        = data.azurerm_automation_account.dsc.primary_key
  dsc_endpoint                   = data.azurerm_automation_account.dsc.endpoint

}





