# Base Resources
locals {
  zones = 3
}

module "resourcegroup" {
  source = "../../TFmodules/resource-group"
  for_each = var.regions
  
    name     = "${each.key}-${var.rg_name}"
    location = each.key

}

# output rg_locations {
#   value       = { for p in sort(keys(var.regions)) : p => azurerm_resource_group[p].location }
# }


# VNETS

module "vnet1" {
  source = "../../TFmodules/networking/vnet"
  for_each = var.regions

  resource_group_name = module.resourcegroup[each.key].rg_name
  location            = module.resourcegroup[each.key].rg_location

  vnet_name             = "${each.key}-vnet" 
  address_space         = "10.1.0.0/16"
  default_subnet_prefix = "10.1.0.0/24"
  dns_servers = [
    "168.63.129.16"
  ]

}

# Apply NSG Rules on Subnets

module "nsg_vnet1" {
    source = "../../TFmodules/networking/nsgrules"
    for_each = var.regions

    resource_group_name = module.resourcegroup[each.key].rg_name
    network_security_group_name = module.vnet1[each.key].defaultsub_nsg_name
}



# # Peering between VNET1 and VNET2

# module "peeringX" {
#   source = "../../TFmodules/networking/peering"

#   resource_group_nameA = azurerm_resource_group.resourcegroup.name
#   resource_group_nameB = azurerm_resource_group.resourcegroup.name
#   netA_name            = module.vnet1.vnet_name
#   netA_id              = module.vnet1.vnet_id
#   netB_name            = module.vnet2.vnet_name
#   netB_id              = module.vnet2.vnet_id

# }

# Deploy a Linux Servers in VNET1

# module "create_linuxserver_vnet1" {
#   source   = "../../TFmodules/zs_compute_linux"
#   for_each = var.hostinfo1

#   resource_group_name = module.vnet1[each.key].vnet_rg
#   location            = module.vnet1[each.key].vnet_location
#   vnet_subnet_id      = module.vnet1[each.key].default_subnet_id

#   tags                    = var.tags
#   compute_hostname_prefix = replace(each.value.vm_size, "_", "-")
#   compute_instance_count  = local.zones

#   vm_size              = each.value.vm_size
#   os_publisher         = "RedHat"
#   os_offer             = "RHEL"
#   os_sku               = "7-LVM"
#   os_version           = "latest"
#   storage_account_type = var.storage_account_type
#   admin_username                = var.admin_username
#   enable_accelerated_networking = true
#   boot_diag_SA_endpoint         = var.boot_diag_SA_endpoint

# }

