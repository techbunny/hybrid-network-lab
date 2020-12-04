# Base Resources
locals {

  zones = 3

}


module "resourcegroup" {
  source = "../../TFmodules/resource-group"
  for_each = var.regioninfo
  
    name     = "${each.key}-${var.rg_name}"
    location = each.key
    tags     = var.tags

}


# VNETS

module "vnet1" {
  source = "../../TFmodules/networking/vnet"
  for_each = var.regioninfo

  resource_group_name = module.resourcegroup[each.key].rg_name
  location            = module.resourcegroup[each.key].rg_location

  vnet_name             = "${each.key}-vnet" 
  address_space         = "${each.value.cidr_net}/16"
  default_subnet_prefix = "${each.value.cidr_net}/24"
  dns_servers = [
    "168.63.129.16"
  ]

}

# Apply NSG Rules on Subnets

module "nsg_vnet1" {
    source = "../../TFmodules/networking/nsgrules"
    for_each = var.regioninfo

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

# locals {

#   regions = [
#     for key, key in var.regioninfo : {
#       key = key
#       location = key
#     }
#   ]
#   vmsize = [
#     for key, key in var.vminfo : {
#       key = key
#       vm_size = value
#     }
#   ]
#   region_vms = [
#     for pair in setproduct(local.regions, local.region_vms) : {
#       regions_key = pair[0].key
#       vmsize_key = pair[1].key
#     }
#   ]
# }

# module "create_linuxserver_on_vnet" {
#   source   = "../../TFmodules/zs_compute_linux"
#   # for_each = {
#   #   for region in local.region_vms : 
#   # }
#   # for_each = var.regioninfo

#   resource_group_name = module.resourcegroup[each.key].rg_name
#   location            = module.resourcegroup[each.key].rg_location
#   vnet_subnet_id      = module.vnet1[each.key].default_subnet_id

#   tags                    = var.tags
#   # compute_hostname_prefix = replace(each.value.vm_size, "_", "-")
#   compute_hostname_prefix = "vmsize"
#   compute_instance_count  = each.value.zones

#   vm_size              = var.vminfo
#   os_publisher         = "RedHat"
#   os_offer             = "RHEL"
#   os_sku               = "7-LVM"
#   os_version           = "latest"
#   storage_account_type = var.storage_account_type
#   admin_username                = var.admin_username
#   enable_accelerated_networking = true
#   boot_diag_SA_endpoint         = var.boot_diag_SA_endpoint

# }

