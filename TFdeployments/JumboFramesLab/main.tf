# Base Resources

resource "azurerm_resource_group" "resourcegroup" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_network_ddos_protection_plan" "ddosprotection" {
  name                = var.ddos_plan_name
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location
}

# VNETS

module "vnet1" {
  source = "../../TFmodules/networking/vnet"

  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location

  vnet_name             = "jumboframes"
  ddos_plan_id          = azurerm_network_ddos_protection_plan.ddosprotection.id
  address_space         = "10.2.0.0/16"
  default_subnet_prefix = "10.2.0.0/24"
  dns_servers = [
    "168.63.129.16"
  ]

}

module "vnet2" {
  source = "../../TFmodules/networking/vnet"

  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location

  vnet_name             = "jumbopeered"
  ddos_plan_id          = azurerm_network_ddos_protection_plan.ddosprotection.id
  address_space         = "10.3.0.0/16"
  default_subnet_prefix = "10.3.0.0/25"
  dns_servers = [
    "168.63.129.16"
  ]

}

# Apply NSG Rules on Subnets

module "nsg_vnet1" {
    source = "../../TFmodules/networking/nsgrules"

    resource_group_name = azurerm_resource_group.resourcegroup.name
    network_security_group_name = module.vnet1.defaultsub_nsg_name
}

module "nsg_vnet2" {
    source = "../../TFmodules/networking/nsgrules"

    resource_group_name = azurerm_resource_group.resourcegroup.name
    network_security_group_name = module.vnet2.defaultsub_nsg_name
}

# Peering between VNET1 and VNET2

module "peeringX" {
  source = "../../TFmodules/networking/peering"

  resource_group_nameA = azurerm_resource_group.resourcegroup.name
  resource_group_nameB = azurerm_resource_group.resourcegroup.name
  netA_name            = module.vnet1.vnet_name
  netA_id              = module.vnet1.vnet_id
  netB_name            = module.vnet2.vnet_name
  netB_id              = module.vnet2.vnet_id

}

# Deploy a Linux Servers in VNET1

module "create_linuxserver_vnet1" {
  source   = "../../TFmodules/zs_compute_linux"
  for_each = var.hostinfo1

  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location
  vnet_subnet_id      = module.vnet1.default_subnet_id

  tags                    = var.tags
  compute_hostname_prefix = module.vnet1.vnet_name
  compute_instance_count  = 1

  vm_size              = each.value.vm_size
  os_publisher         = "RedHat"
  os_offer             = "RHEL"
  os_sku               = "7-LVM"
  os_version           = "latest"
  storage_account_type = var.storage_account_type
  # compute_boot_volume_size_in_gb = var.compute_boot_volume_size_in_gb
  admin_username                = var.admin_username
  enable_accelerated_networking = true
  boot_diag_SA_endpoint         = var.boot_diag_SA_endpoint
  zone                          = each.value.zone

}

# Deploy a Linux Servers in VNET2

module "create_linuxserver_vnet2" {
  source   = "../../TFmodules/zs_compute_linux"
  for_each = var.hostinfo2

  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location
  vnet_subnet_id      = module.vnet2.default_subnet_id

  tags                    = var.tags
  compute_hostname_prefix = module.vnet2.vnet_name
  compute_instance_count  = 1

  vm_size              = each.value.vm_size
  os_publisher         = "RedHat"
  os_offer             = "RHEL"
  os_sku               = "7-LVM"
  os_version           = "latest"
  storage_account_type = var.storage_account_type
  # compute_boot_volume_size_in_gb = var.compute_boot_volume_size_in_gb
  admin_username                = var.admin_username
  enable_accelerated_networking = true
  boot_diag_SA_endpoint         = var.boot_diag_SA_endpoint
  zone                          = each.value.zone

}
