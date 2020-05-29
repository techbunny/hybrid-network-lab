resource "azurerm_resource_group" "rg1" {
  name     = var.rg_name1
  location = var.location1
  tags     = var.tags
}

resource "azurerm_resource_group" "rg2" {
  name     = var.rg_name2
  location = var.location2
  tags     = var.tags
}

resource "azurerm_resource_group" "rg3" {
  name     = var.rg_name3
  location = var.location3
  tags     = var.tags
}

# Deploy three VNETS with Default Subnets and Bastion Hosts

module "vnet1" {
  source = "../../TFmodules/networking/vnet"

  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location

  vnet_name             = "vnet1"
  address_space         = "10.10.0.0/16"
  default_subnet_prefix = "10.10.0.0/24"
  dns_servers = [
    "168.63.129.16",
  ]

}

module "bastion_vnet1" {
  source = "../../TFmodules/bastion"

  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = module.vnet1.vnet_name
  subnet_cidr          = "10.10.250.0/24"
  location             = azurerm_resource_group.rg1.location

}

module "vnet2" {
  source = "../../TFmodules/networking/vnet"

  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location

  vnet_name             = "vnet2"
  address_space         = "10.20.0.0/16"
  default_subnet_prefix = "10.20.0.0/24"
  dns_servers = [
    "168.63.129.16",
  ]
}

module "bastion_vnet2" {
  source = "../../TFmodules/bastion"

  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = module.vnet2.vnet_name
  subnet_cidr          = "10.20.250.0/24"
  location             = azurerm_resource_group.rg2.location

}

module "vnet3" {
  source = "../../TFmodules/networking/vnet"

  resource_group_name = azurerm_resource_group.rg3.name
  location            = azurerm_resource_group.rg3.location

  vnet_name             = "vnet3"
  address_space         = "10.30.0.0/16"
  default_subnet_prefix = "10.30.0.0/24"
  dns_servers = [
    "168.63.129.16",
  ]
}

module "bastion_vnet3" {
  source = "../../TFmodules/bastion"

  resource_group_name  = azurerm_resource_group.rg3.name
  virtual_network_name = module.vnet3.vnet_name
  subnet_cidr          = "10.30.250.0/24"
  location             = azurerm_resource_group.rg3.location

}

# Gateway Subnets

resource "azurerm_subnet" "vnet1_gw" {
  name                 = "GatewaySubnet"
  virtual_network_name = module.vnet1.vnet_name
  resource_group_name = azurerm_resource_group.rg1.name
  address_prefixes       = ["10.10.251.0/24"]

  depends_on = [module.vnet1]
}

resource "azurerm_subnet" "vnet2_gw" {
  name                 = "GatewaySubnet"
  virtual_network_name = module.vnet2.vnet_name
  resource_group_name = azurerm_resource_group.rg2.name
  address_prefixes       = ["10.20.251.0/24"]

  depends_on = [module.vnet2]
}


# Public IP Addresses for VPN Gateways

resource "azurerm_public_ip" "gwip1" {
  name                = "gwip1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location

  allocation_method = "Dynamic"
  # depends_on = [azurerm_subnet.vnet1_gw]
}

resource "azurerm_public_ip" "gwip2" {
  name                = "gwip2"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location

  allocation_method = "Dynamic"
  # depends_on = [azurerm_subnet.vnet2_gw]
}

# # Deploy VNET Gateways 

resource "azurerm_virtual_network_gateway" "gw1" {
  name                = "vnet1-gw"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gwip1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id  = azurerm_subnet.vnet1_gw.id
  }
}
resource "azurerm_virtual_network_gateway" "gw2" {
  name                = "vnet2-gw"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gwip2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id  = azurerm_subnet.vnet2_gw.id
  }
}

# Add Local Gateways and connect S2S VPN

resource "azurerm_local_network_gateway" "vnet1" {
  name                = "vnet1_localgw_to_vnet2"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  gateway_address     = azurerm_public_ip.gwip2.ip_address
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_local_network_gateway" "vnet2" {
  name                = "vnet2_localgw_to_vnet1"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  gateway_address     = azurerm_public_ip.gwip1.ip_address  
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_virtual_network_gateway_connection" "vnet1" {
  name                = "vnet1tovnet2"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.gw1.id
  local_network_gateway_id   = azurerm_local_network_gateway.vnet1.id

  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}

resource "azurerm_virtual_network_gateway_connection" "vnet2" {
  name                = "vnet2tovnet1"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.gw2.id
  local_network_gateway_id   = azurerm_local_network_gateway.vnet2.id

  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}

# Peering between VNET2 and VNET3

module "peeringX" {
  source = "../../TFmodules/networking/peering"

  resource_group_nameA = azurerm_resource_group.rg2.name
  resource_group_nameB = azurerm_resource_group.rg3.name
  netA_name            = module.vnet2.vnet_name
  netA_id              = module.vnet2.vnet_id
  netB_name            = module.vnet3.vnet_name
  netB_id              = module.vnet3.vnet_id

}

# LB for Outbound Access

module "outbound_lb_vnet1" {
  source = "../../TFmodules/loadbalancer/lb_external"

  lbname   = "lb-outbound-only"
  location = azurerm_resource_group.rg1.location
  rg_name  = azurerm_resource_group.rg1.name
  subnetName              = module.vnet1.default_subnet_name
  core_vnet_name          = module.vnet1.vnet_name
  core_rg_name            = azurerm_resource_group.rg1.name
  compute_hostname_prefix = "${azurerm_resource_group.rg1.name}-outbound"


}

module "outbound_lb_vnet2" {
  source = "../../TFmodules/loadbalancer/lb_external"

  lbname   = "lb-outbound-only"
  location = azurerm_resource_group.rg2.location
  rg_name  = azurerm_resource_group.rg2.name
  subnetName              = module.vnet2.default_subnet_name
  core_vnet_name          = module.vnet2.vnet_name
  core_rg_name            = azurerm_resource_group.rg2.name
  compute_hostname_prefix = "${azurerm_resource_group.rg2.name}-outbound"


}


# Deploy a Windows Server VM for DNS

module "create_windowsserver_vnet1" {
  source = "../../TFmodules/avset_compute"

  location = azurerm_resource_group.rg1.location
  resource_group_name  = azurerm_resource_group.rg1.name
  vnet_subnet_id      = module.vnet1.default_subnet_id

  tags                           = var.tags
  compute_hostname_prefix        = "DNS-rg1"
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
  backendpool_id                 = module.outbound_lb_vnet1.vm_backendpool_id
  create_data_disk               = 1
  assign_bepool                  = 1
}

# APIM Module

resource "azurerm_subnet" "vnet2_apim" {
  name                 = "apimSubnet"
  virtual_network_name = module.vnet2.vnet_name
  resource_group_name = azurerm_resource_group.rg2.name
  address_prefixes       = ["10.20.1.0/24"]

  depends_on = [module.vnet2]
}

module "create_apim" {
  source = "../../TFmodules/apim"

  rg_name             = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  subnet_id           = azurerm_subnet.vnet2_apim.id
  event_grid_sub_name = "subname"
  service_bus_name = "servicebustestjkc1234"
  apim_name = "apimjkc1234"
  storage_name = "apimstorageforme"
}

# Deploy a Windows Server VM in VNET2 to testing

module "create_windowsserver_vnet2" {
  source = "../../TFmodules/avset_compute"

  location = azurerm_resource_group.rg2.location
  resource_group_name  = azurerm_resource_group.rg2.name
  vnet_subnet_id      = module.vnet2.default_subnet_id

  tags                           = var.tags
  compute_hostname_prefix        = "srv-rg2"
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
  backendpool_id                 = module.outbound_lb_vnet2.vm_backendpool_id
  create_data_disk               = 1
  assign_bepool                  = 1
}

# # Deploy Application Gateway

# module "appgateway" {
#   source = "./modules/appgateway"

#   appgw_name          = "lab-appgw"
#   location            = module.vnets.rg_cloud_location
#   resource_group_name = module.vnets.rg_cloud
#   virtual_network_name   = module.vnets.vnet2_name

#   }


# TODO
# Add NSG to open RDP to Jumpbox
# LogicApps ISE
# APIM
# Domain Controllers
