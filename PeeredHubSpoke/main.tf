resource "azurerm_resource_group" "hubspoke" {
  name     = var.rg_name_hubspoke
  location = var.location_hubspoke
  tags     = var.tags     
}

# Deploy three VNETS

module "vnets" {
  source = "./modules/vnets"

  resource_group_name = azure_resource_group.hubspoke.name
  resource_group_location = azure_resource_group.hubspoke.location
  vnet1_name = "hub"
  address_space1 = "10.0.0.0/16"
  vnet2_name = "prod"
  address_space2 = "10.10.0.0/16"
  vent3_name = "dev"
  address_space3 = "172.137.0.0/16"
  }


# Peering between VNET1 and VNET2

resource "azurerm_virtual_network_peering" "vnet_peer_1" {
  name                         = "peer1to2"
  resource_group_name          = module.vnets.rg_cloud
  virtual_network_name         = module.vnets.vnet1_name
  remote_virtual_network_id    = module.vnets.vnet2_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
  depends_on                   = [azurerm_virtual_network_gateway_connection.fakeonprem, azurerm_virtual_network_gateway_connection.cloud]

}

resource "azurerm_virtual_network_peering" "vnet_peer_2" {
  name                         = "peer2to1"
  resource_group_name          = module.vnets.rg_cloud
  virtual_network_name         = module.vnets.vnet2_name
  remote_virtual_network_id    = module.vnets.vnet1_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_virtual_network_gateway_connection.fakeonprem, azurerm_virtual_network_gateway_connection.cloud]
  

}

# Peering between VNET1 and VNET3

resource "azurerm_virtual_network_peering" "vnet_peer_1" {
  name                         = "peer1to2"
  resource_group_name          = module.vnets.rg_cloud
  virtual_network_name         = module.vnets.vnet1_name
  remote_virtual_network_id    = module.vnets.vnet2_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
  depends_on                   = [azurerm_virtual_network_gateway_connection.fakeonprem, azurerm_virtual_network_gateway_connection.cloud]

}

resource "azurerm_virtual_network_peering" "vnet_peer_2" {
  name                         = "peer2to1"
  resource_group_name          = module.vnets.rg_cloud
  virtual_network_name         = module.vnets.vnet2_name
  remote_virtual_network_id    = module.vnets.vnet1_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_virtual_network_gateway_connection.fakeonprem, azurerm_virtual_network_gateway_connection.cloud]
  

}

# Peering between VNET2 and VNET3

resource "azurerm_virtual_network_peering" "vnet_peer_1" {
  name                         = "peer1to2"
  resource_group_name          = module.vnets.rg_cloud
  virtual_network_name         = module.vnets.vnet1_name
  remote_virtual_network_id    = module.vnets.vnet2_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
  depends_on                   = [azurerm_virtual_network_gateway_connection.fakeonprem, azurerm_virtual_network_gateway_connection.cloud]

}

resource "azurerm_virtual_network_peering" "vnet_peer_2" {
  name                         = "peer2to1"
  resource_group_name          = module.vnets.rg_cloud
  virtual_network_name         = module.vnets.vnet2_name
  remote_virtual_network_id    = module.vnets.vnet1_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_virtual_network_gateway_connection.fakeonprem, azurerm_virtual_network_gateway_connection.cloud]
  

}

# Deploy a Windows Server VM in Hub

module "create_windowsserver_vnet1" {
  source = "./modules/compute"

  resource_group_name = module.vnets.rg_cloud
  location            = module.vnets.rg_cloud_location
  vnet_subnet_id      = module.vnets.vnet1_subnet_id

  tags                           = var.tags
  compute_hostname_prefix        = var.compute_hostname_prefix
  compute_instance_count         = var.compute_instance_count

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
  source = "./modules/compute"

  resource_group_name = module.vnets.rg_cloud
  location            = module.vnets.rg_cloud_location
  vnet_subnet_id      = module.vnets.vnet3_subnet_id

  tags                           = var.tags
  compute_hostname_prefix        = var.compute_hostname_prefix
  compute_instance_count         = var.compute_instance_count

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

module "aks" {
  source = "./modules/aks"

  resource_group_name = module.vnets.rg_cloud
  location            = module.vnets.rg_cloud_location
  vnet_network_name   = module.vnets.vnet2_name
  prefix              = var.prefix
  address_prefix      = var.subnet_cidr
  kubernetes_client_id     = var.kubernetes_client_id
  kubernetes_client_secret = var.kubernetes_client_secret
  admin_password      = var.admin_password

}

