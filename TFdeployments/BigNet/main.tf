### DEPLOYMENT NOTE ###
# Because of the dependency of the Peering Module on
# the results of the VNET module (which isn't known until
# deployment), this must be deployed twice, first to just
# deploy the VNETs so they are known for the next run.

# 1) terraform apply -target=module.vnet1
# 2) terraform apply

## Creates single RG for test deployment

module "resourcegroup" {
  source = "../../TFmodules/resource-group"
  
    name     = var.rg_name
    location = var.rg_location
    tags     = var.tags

}

# LOCALS used for manipulating the data needed for 
# VM deployment and VNET peering.

locals {

# Converts the list of VM Size Skus to a set
  vminfo = [
    for key, vm_size in toset(var.vm_sizes) : {
      key = key
      vm_size = key
      os_sku = var.default_os_sku
    }
  ]

  vminfo_gen2 = [
    for key, vm_size in toset(var.vm_sizes_gen2) : {
      key = key
      vm_size = key
      os_sku = var.gen2_os_sku
    }
  ]

# Combines both lists from above into one. 
  all_vms =  [
    for allvms in concat(local.vminfo, local.vminfo_gen2) : allvms
  ]
  
 
 # Creates a map of all requested regions for deployment, 
 # and to be used by the networking modules. 
  regioninfo = [
    for key, region in var.regioninfo : {
      key = key
      region = key
    }
  ]
  
# Creates a map of all requested VM types across all requested regions.
  regions_with_sizes = [
    #for pair in setproduct(local.regioninfo, local.vminfo) : {
    for pair in setproduct(local.regioninfo, local.all_vms) : {
      region_key  = pair[0].key
      vm_size = pair[1].vm_size
      os_sku = pair[1].os_sku
    }
  ]

 # Formats the exclusion list for regions that can't support a subset
 # of the VM size skus, for both GEN1 and GEN2 OS skus
  exclusions_list = [
    for region_key, vm_size in var.exclusions : {
      region_key = region_key
      vm_size = vm_size
      os_sku = var.default_os_sku

    }
  ]

  exclusions_list_gen2 = [
    for region_key, vm_size in var.exclusions : {
      region_key = region_key
      vm_size = vm_size
      os_sku = var.gen2_os_sku

    }
  ]

# Combines both lists from above into one. 
  all_exclusions =  [
    for all_ex in concat(local.exclusions_list, local.exclusions_list_gen2) : all_ex
  ]

# Removes the specified exclusions
  regions_with_exclusions = [
    for pair in setsubtract(local.regions_with_sizes, local.all_exclusions) : pair
  ]

# Creates a final list of VMs to deploy in each region with additional information
# needed regarding vnet/subnet destination and number of zones supported, each zone will
# have a VM deployed.

  regions_with_sizes_final = [
    for vm in local.regions_with_exclusions : {
      region_key  = vm.region_key
      vm_size = vm.vm_size
      vm_prefix = vm.vm_size
      vnet_subnet_id = module.vnet1[vm.region_key].default_subnet_id
      zones = module.vnet1[vm.region_key].zones
      os_sku = vm.os_sku
    }
  ]

# Creates a map all possible pairs (cartesian product) of VNETs for peering. 
# Includes "Same-to-Same" pairs that will be filtered out by the Peering module.
  vnet_to_vnet = [
    for pair in setproduct(local.regioninfo, local.regioninfo) : {
      region_A  = module.vnet1[pair[0].key].vnet_location
      name_A = module.vnet1[pair[0].key].vnet_name
      region_B  = module.vnet1[pair[1].key].vnet_location
      name_B = module.vnet1[pair[1].key].vnet_name
      id_B = module.vnet1[pair[1].key].vnet_id
    }
    if pair[0] != pair[1]
  ]

}

## OUTPUTS for REFERENCE ###
# Use to see the results of the locals #

output "region_with_sizes_final" {
  value = [
    for vm in local.regions_with_exclusions : {
      region_key  = vm.region_key
      vm_size = vm.vm_size
      vm_prefix = vm.vm_size
      vnet_subnet_id = module.vnet1[vm.region_key].default_subnet_id
      zones = module.vnet1[vm.region_key].zones
      os_sku = vm.os_sku
    }
  ]
}

# output "vnet_to_vnet" {
#   value = [
#     for pair in setproduct(local.regioninfo, local.regioninfo) : {
#       region_A  = module.vnet1[pair[0].key].vnet_location
#       name_A = module.vnet1[pair[0].key].vnet_name
#       id_A = module.vnet1[pair[0].key].vnet_id
#       region_B  = module.vnet1[pair[1].key].vnet_location
#       name_B = module.vnet1[pair[1].key].vnet_name
#       id_B = module.vnet1[pair[1].key].vnet_id
#     }
#   ]
# }


## VNETS

module "vnet1" {
  source = "../../TFmodules/networking/vnet"
  for_each = var.regioninfo
  depends_on = [module.resourcegroup]

  resource_group_name = var.rg_name
  location            = each.key

  vnet_name             = "${each.key}-vnet" 
  address_space         = "${each.value.cidr_net}/16"
  default_subnet_prefix = "${each.value.cidr_net}/24"
  dns_servers = [
    "168.63.129.16"
  ]
  # This is a "helper" variable needed later for the VM module.
  # This module stashes the result as a VNET output to be picked up
  # the local.regions_with_sizes variable. 
  region_zones = each.value.zones

}

## Apply NSG Rules on Subnets

module "nsg_vnet1" {
    source = "../../TFmodules/networking/nsgrules"
    for_each = var.regioninfo
    

    resource_group_name = var.rg_name
    network_security_group_name = module.vnet1[each.key].defaultsub_nsg_name
}

## Peering between each VNET

module "peering" {
  source = "../../TFmodules/networking/peering"
  for_each = {
    for peer in local.vnet_to_vnet : "${peer.name_A}.${peer.name_B}" => peer
   }

  resource_group_nameA = var.rg_name
  resource_group_nameB = var.rg_name
  netA_name            = each.value.name_A
  netB_name            = each.value.name_B  
  netB_id              = each.value.id_B

}

## Deploy a Linux Servers in VNET
# TO DO: Variablize the os_sku to account for VMs that support only Gen-2

module "create_linuxserver_on_vnet" {
  source   = "../../TFmodules/zs_compute_linux"
  for_each = {
    for vm in local.regions_with_sizes_final : "${vm.region_key}.${vm.vm_size}" => vm
  }

  resource_group_name = var.rg_name
  location = each.value.region_key
  vnet_subnet_id = each.value.vnet_subnet_id
  
  tags                    = var.tags
  compute_hostname_prefix = replace(each.value.vm_size, "_", "-")
  compute_instance_count  = each.value.zones
  vm_size              = each.value.vm_size
  os_publisher         = "RedHat"
  os_offer             = "RHEL"
  os_sku               = each.value.os_sku
  os_version           = "latest"
  storage_account_type = var.storage_account_type
  admin_username                = var.admin_username
  enable_accelerated_networking = true
  boot_diag_SA_endpoint         = var.boot_diag_SA_endpoint

}



