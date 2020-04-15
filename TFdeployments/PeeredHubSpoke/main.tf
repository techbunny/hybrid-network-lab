resource "azurerm_resource_group" "hubspoke" {
  name     = var.rg_name_hubspoke
  location = var.location_hubspoke
  tags     = var.tags     
}

# Deploy three VNETS with Subnets

module "vnet1" {
  source = "../../TFmodules/networking/vnet"

  resource_group_name = azurerm_resource_group.hubspoke.name
  location            = azurerm_resource_group.hubspoke.location

  vnet_name          = "hub"
  address_space     = "10.0.0.0/16"
  default_subnet_prefix = "10.0.0.0/24"

}

module "vnet2" {
  source = "../../TFmodules/networking/vnet"

  resource_group_name = azurerm_resource_group.hubspoke.name
  location            = azurerm_resource_group.hubspoke.location

  vnet_name          = "prod"
  address_space      = "10.10.0.0/16"
  default_subnet_prefix = "10.10.0.0/24"
}

module "vnet3" {
  source = "../../TFmodules/networking/vnet"

  resource_group_name = azurerm_resource_group.hubspoke.name
  location            = azurerm_resource_group.hubspoke.location

  vnet_name          = "dev"
  address_space      = "172.137.0.0/16"
  default_subnet_prefix = "172.137.0.0/24"
  }




# # Peering between VNET1 and VNET2

# resource "azurerm_virtual_network_peering" "vnet_peer_1" {
#   name                         = "peer1to2"
#   resource_group_name          = azurerm_resource_group.hubspoke.name
#   virtual_network_name         = module.vnets.vnet1_name
#   remote_virtual_network_id    = module.vnets.vnet2_id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = false
#   allow_gateway_transit        = false
#   use_remote_gateways          = false
  
# }

# resource "azurerm_virtual_network_peering" "vnet_peer_2" {
#   name                         = "peer2to1"
#   resource_group_name          = azurerm_resource_group.hubspoke.name
#   virtual_network_name         = module.vnets.vnet2_name
#   remote_virtual_network_id    = module.vnets.vnet1_id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = false
#   allow_gateway_transit        = false
#   use_remote_gateways          = false
 

# }

# # Peering between VNET1 and VNET3

# resource "azurerm_virtual_network_peering" "vnet_peer_1b" {
#   name                         = "peer1to3"
#   resource_group_name          = azurerm_resource_group.hubspoke.name
#   virtual_network_name         = module.vnets.vnet1_name
#   remote_virtual_network_id    = module.vnets.vnet3_id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = false
#   allow_gateway_transit        = false
#   use_remote_gateways          = false
  
# }

# resource "azurerm_virtual_network_peering" "vnet_peer_3" {
#   name                         = "peer3to1"
#   resource_group_name          = azurerm_resource_group.hubspoke.name
#   virtual_network_name         = module.vnets.vnet3_name
#   remote_virtual_network_id    = module.vnets.vnet1_id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = false
#   allow_gateway_transit        = false
#   use_remote_gateways          = false
  
# }

# # Peering between VNET2 and VNET3

# resource "azurerm_virtual_network_peering" "vnet_peer_2b" {
#   name                         = "peer2to3"
#   resource_group_name          = azurerm_resource_group.hubspoke.name
#   virtual_network_name         = module.vnets.vnet2_name
#   remote_virtual_network_id    = module.vnets.vnet3_id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = false
#   allow_gateway_transit        = false
#   use_remote_gateways          = false
  
# }

# resource "azurerm_virtual_network_peering" "vnet_peer_3b" {
#   name                         = "peer3to2"
#   resource_group_name          = azurerm_resource_group.hubspoke.name
#   virtual_network_name         = module.vnets.vnet3_name
#   remote_virtual_network_id    = module.vnets.vnet2_id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = false
#   allow_gateway_transit        = false
#   use_remote_gateways          = false
 

# }

# Deploy a Windows Server VM in Hub

module "create_windowsserver_vnet1" {
  source = "../../TFmodules/compute"

  resource_group_name          = azurerm_resource_group.hubspoke.name
  location                     = azurerm_resource_group.hubspoke.location
  vnet_subnet_id               = module.vnet1.default_subnet_id

  tags                           = var.tags
  compute_hostname_prefix        = "hub-server"
  compute_instance_count         = 1

  vm_size                        = var.vm_size
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
  create_public_ip               = 0
  create_data_disk               = 0
  assign_bepool                  = 0
  create_av_set                  = 0
}

# Deploy a Windows Server VM in Staging

module "create_windowsserver_vnet3" {
  source = "../../TFmodules/compute"

  resource_group_name          = azurerm_resource_group.hubspoke.name
  location                     = azurerm_resource_group.hubspoke.location
  vnet_subnet_id               = module.vnet3.default_subnet_id

  tags                           = var.tags
  compute_hostname_prefix        = "dev-server"
  compute_instance_count         = 1

  vm_size                        = var.vm_size
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
  create_public_ip               = 0
  create_data_disk               = 0
  assign_bepool                  = 0
  create_av_set                  = 0
}


# Deploy Windows AKS Cluster


resource "azurerm_subnet" "aks" {
  name                 = "aksSubnet"
  resource_group_name  = azurerm_resource_group.hubspoke.name
  virtual_network_name = module.vnet2.vnet_name
  address_prefix       = "10.10.128.0/17"
}

module "aks" {
  source = "../../TFmodules/aks"

  resource_group_name = azurerm_resource_group.hubspoke.name
  location            = azurerm_resource_group.hubspoke.location
  vnet_network_name   = module.vnet2.vnet_name
  prefix              = var.prefix
  address_prefix      = var.subnet_cidr
  kubernetes_client_id     = var.kubernetes_client_id
  kubernetes_client_secret = var.kubernetes_client_secret
  admin_password      = var.admin_password

}

