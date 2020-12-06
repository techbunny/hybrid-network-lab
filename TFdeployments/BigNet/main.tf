# Locals used for VM deployment
locals {
  vm_sizes = [
    "Standard_D2_v2",
    "Standard_D4_v3",
    "Standard_DS2_v2"]
 
  regioninfo = [
    for key, region in var.regioninfo : {
      key = key
      region = key
    }
  ]
  vminfo = [
    for key, vm_size in toset(local.vm_sizes) : {
      key = key
      vm_size = key
    }
  ]
  
  region_with_sizes = [
    for pair in setproduct(local.regioninfo, local.vminfo) : {
      region_key  = pair[0].key
      vm_size = pair[1].vm_size
      vm_prefix = pair[1].vm_size
      vnet_subnet_id = module.vnet1[pair[0].key].default_subnet_id

    }
  ]
  vnet_list = [module.vnet1]

  vnets = [
    for key in local.vnet_list : {
      key = key
    }
  ]

  zones = 3

  vnet_peers = [
    for pair in setproduct(local.vnets, local.vnets) : {
      vnetA_region = pair[0].key
      vnetB_region = pair[1].key
    }
  ]
}

  output "vnets" {
    value = [
    for key in local.vnet_list : {
      key = key

    }
   ]
   }

   output "vnet_peers" {
    value = [
    for pair in setproduct(local.vnets, local.vnets) : {
      vnetA_region = pair[0].key
      vnetB_region = pair[1].key

    }
    ]
   }

# output "region_with_sizes" {
#   value = [
#     for pair in setproduct(local.regioninfo, local.vminfo) : {
#       region_key  = pair[0].key
#       vm_size = pair[1].vm_size
#       vm_prefix = pair[1].vm_size
#       vnet_subnet_id = module.vnet1[pair[0].key].default_subnet_id

#     }
#   ]
# }

# Create single RG for test deployment

module "resourcegroup" {
  source = "../../TFmodules/resource-group"
  
    name     = var.rg_name
    location = var.rg_location
    tags     = var.tags

}

# VNETS

module "vnet1" {
  source = "../../TFmodules/networking/vnet"
  for_each = var.regioninfo

  resource_group_name = var.rg_name
  location            = each.key

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

    resource_group_name = var.rg_name
    network_security_group_name = module.vnet1[each.key].defaultsub_nsg_name
}



# # Peering between VNET1 and VNET2

module "peeringX" {
  source = "../../TFmodules/networking/peering"
  for_each = {
    for peer in local.vnet_peers : "${peer.vnetA_region}.${peer.vnetB_region}" => peer
  }

  resource_group_nameA = var.rg_name
  resource_group_nameB = var.rg_name
  netA_name            = module.vnet1.vnet_name
  netA_id              = module.vnet1.vnet_id
  netB_name            = module.vnet1.vnet_name
  netB_id              = module.vnet1.vnet_id

}

# Deploy a Linux Servers in VNET

# module "create_linuxserver_on_vnet" {
#   source   = "../../TFmodules/zs_compute_linux"
#   for_each = {
#     for vm in local.region_with_sizes : "${vm.region_key}.${vm.vm_size}" => vm
#   }

#   resource_group_name = var.rg_name
#   location = each.value.region_key
#   vnet_subnet_id = each.value.vnet_subnet_id
  
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


