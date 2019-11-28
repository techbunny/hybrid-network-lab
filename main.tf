# Deploy three VNETS

module "vnets" {
  source = "./modules/vnets"
  }


# Deploy VNET Gateways 

resource "azurerm_virtual_network_gateway" "gw2" {
  name                = "vnet2-gw"
  location            = module.vnets.rg_cloud_location
  resource_group_name = module.vnets.rg_cloud

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = module.vnets.gwip2_pip_id
    private_ip_address_allocation = "Dynamic"
    subnet_id  = module.vnets.gw2_subnet_id
  }
}
resource "azurerm_virtual_network_gateway" "gw3" {
  name                = "vnet3-gw"
  location            = module.vnets.rg_fakeonprem_location
  resource_group_name = module.vnets.rg_fakeonprem

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = module.vnets.gwip3_pip_id
    private_ip_address_allocation = "Dynamic"
    subnet_id  = module.vnets.gw3_subnet_id
  }
}

# Add Local Gateways and connect S2S VPN

data "azurerm_public_ip" "gw2" {
  name                = module.vnets.gwip2_pip_name
  resource_group_name = module.vnets.rg_cloud
  depends_on          = [azurerm_virtual_network_gateway.gw2]
}

data "azurerm_public_ip" "gw3" {
  name                = module.vnets.gwip3_pip_name
  resource_group_name = module.vnets.rg_fakeonprem
  depends_on          = [azurerm_virtual_network_gateway.gw3]
}

resource "azurerm_local_network_gateway" "vnet2" {
  name                = "vnet2_localgw_to_vnet3"
  location            = module.vnets.rg_cloud_location
  resource_group_name = module.vnets.rg_cloud
  gateway_address     = data.azurerm_public_ip.gw3.ip_address  #Need to get IP
  address_space       = ["172.30.1.0/24"]
}

resource "azurerm_local_network_gateway" "vnet3" {
  name                = "vnet3_localgw_to_vnet2"
  location            = module.vnets.rg_fakeonprem_location
  resource_group_name = module.vnets.rg_fakeonprem
  gateway_address     = data.azurerm_public_ip.gw2.ip_address
  address_space       = ["172.22.1.0/24"]
}

resource "azurerm_virtual_network_gateway_connection" "cloud" {
  name                = "cloud2fakeonprem"
  location            = module.vnets.rg_cloud_location
  resource_group_name = module.vnets.rg_cloud

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.gw2.id
  local_network_gateway_id   = azurerm_local_network_gateway.vnet2.id

  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}

resource "azurerm_virtual_network_gateway_connection" "fakeonprem" {
  name                = "fakeonprem2cloud"
  location            = module.vnets.rg_fakeonprem_location
  resource_group_name = module.vnets.rg_fakeonprem

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.gw3.id
  local_network_gateway_id   = azurerm_local_network_gateway.vnet3.id

  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}

# Peering between VNET1 and VNET2
# Using Remote Gateway 

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

# Deploy VMs as jumpboxes

module "create_jumpbox_vnet1" {
  source = "./modules/compute"

  resource_group_name = module.vnets.rg_cloud
  location            = module.vnets.rg_cloud_location
  vnet_subnet_id      = module.vnets.vnet1_subnet_id

  tags                           = var.tags
  compute_hostname_prefix        = var.compute_hostname_prefix_jumpbox
  compute_instance_count         = var.jumpbox_instance_count
  vm_size                        = var.vm_size
  os_publisher                   = var.os_publisher
  os_offer                       = var.os_offer
  os_sku                         = var.os_sku
  os_version                     = var.os_version
  storage_account_type           = var.storage_account_type
  compute_boot_volume_size_in_gb = var.jumpbox_boot_volume_size_in_gb
  admin_username                 = var.admin_username
  admin_password                 = var.admin_password
  enable_accelerated_networking  = var.enable_accelerated_networking
  boot_diag_SA_endpoint          = var.boot_diag_SA_endpoint
  create_public_ip               = 1
  create_data_disk               = 0
  assign_bepool                  = 0
  create_av_set                  = 0
}

# Deploy Windows AKS Cluster

module "aks" {
  source = "./modules/aks"

  resource_group_name = module.vnets.rg_cloud
  location            = module.vnets.rg_cloud_location
  vnet_network_name   = module.vnets.vnet1_name
  prefix              = var.prefix
  address_prefix      = var.subnet_cidr
  kubernetes_client_id     = var.kubernetes_client_id
  kubernetes_client_secret = var.kubernetes_client_secret
  admin_password      = var.admin_password

}

# Deploy Application Gateway

module "appgateway" {
  source = "./modules/appgateway"

  appgw_name          = "lab-appgw"
  location            = module.vnets.rg_cloud_location
  resource_group_name = module.vnets.rg_cloud
  virtual_network_name   = module.vnets.vnet2_name

  }


# TODO
# LogicApps ISE
# APIM
# Application Gateway
# Domain Controllers
