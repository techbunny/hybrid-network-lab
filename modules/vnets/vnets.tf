# "Cloud" Resources

resource "azurerm_resource_group" "cloud" {
  name     = "${var.rg_name_cloud}"
  location = "${var.location_cloud}"
  tags     = "${var.tags}"     
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "${var.vnet1_name}"
  resource_group_name = "${azurerm_resource_group.cloud.name}"
  location            = "${azurerm_resource_group.cloud.location}"
  address_space       = ["${var.address_space1}"] 
  tags                = "${var.tags}"
}

resource "azurerm_subnet" "vnet1_default" {
  name                 = "default"
  resource_group_name  = "${azurerm_resource_group.cloud.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet1.name}"
  address_prefix       = "172.21.1.0/24"
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "${var.vnet2_name}"
  resource_group_name = "${azurerm_resource_group.cloud.name}"
  location            = "${azurerm_resource_group.cloud.location}"
  address_space       = ["${var.address_space2}"] 
  tags                = "${var.tags}"
}

resource "azurerm_subnet" "vnet2_default" {
  name                 = "default"
  resource_group_name  = "${azurerm_resource_group.cloud.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet2.name}"
  address_prefix       = "172.22.1.0/24"
}

resource "azurerm_subnet" "vnet2_gw" {
  name                 = "GatewaySubnet"
  resource_group_name  = "${azurerm_resource_group.cloud.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet2.name}"
  address_prefix       = "172.22.100.0/24"  # change to 172.22.250.0/24
}


resource "azurerm_virtual_network_peering" "vnet_peer_1" {
  name                         = "peer1"
  resource_group_name          = "${azurerm_resource_group.cloud.name}"
  virtual_network_name         = "${azurerm_virtual_network.vnet1.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.vnet2.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

}

resource "azurerm_virtual_network_peering" "vnet_peer_2" {
  name                         = "peer2"
  resource_group_name          = "${azurerm_resource_group.cloud.name}"
  virtual_network_name         = "${azurerm_virtual_network.vnet2.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.vnet1.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false

}

# Fake "On Prem" Resources

resource "azurerm_resource_group" "fakeonprem" {
  name     = "${var.rg_name_fakeonprem}"
  location = "${var.location_fakeonprem}"
  tags     = "${var.tags}"     
}

resource "azurerm_virtual_network" "vnet3" {
  name                = "${var.vnet3_name}"
  resource_group_name = "${azurerm_resource_group.fakeonprem.name}"
  location            = "${azurerm_resource_group.fakeonprem.location}"
  address_space       = ["${var.address_space3}"] 
  tags                = "${var.tags}"
}

resource "azurerm_subnet" "vnet3_default" {
  name                 = "default"
  resource_group_name  = "${azurerm_resource_group.fakeonprem.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet3.name}"
  address_prefix       = "172.30.1.0/24"
}

resource "azurerm_subnet" "vnet3_gw" {
  name                 = "GatewaySubnet"
  resource_group_name  = "${azurerm_resource_group.fakeonprem.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet3.name}"
  address_prefix       = "172.30.100.0/24"   # change to 172.30.250.0/24
}

# Public IP Addresses for VPN Gateways

resource "azurerm_public_ip" "gwip2" {
  name                = "gwip2"
  location            = "${azurerm_resource_group.cloud.location}"
  resource_group_name = "${azurerm_resource_group.cloud.name}"

  allocation_method = "Dynamic"
}

output "gwip2_pip" {
  value = "${azurerm_public_ip.gwip2.ip_address}"
}

resource "azurerm_public_ip" "gwip3" {
  name                = "gwip3"
  location            = "${azurerm_resource_group.fakeonprem.location}"
  resource_group_name = "${azurerm_resource_group.fakeonprem.name}"

  allocation_method = "Dynamic"
}

output "gwip3_pip" {
  value = "${azurerm_public_ip.gwip3.ip_address}"
}

# Interconnect between VNET Gateways

resource "azurerm_virtual_network_gateway" "gw2" {
  name                = "vnet2-gw"
  location            = "${azurerm_resource_group.cloud.location}"
  resource_group_name = "${azurerm_resource_group.cloud.name}"

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = "${azurerm_public_ip.gwip2.id}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "${azurerm_subnet.vnet2_gw.id}"
  }
}
resource "azurerm_virtual_network_gateway" "gw3" {
  name                = "vnet3-gw"
  location            = "${azurerm_resource_group.fakeonprem.location}"
  resource_group_name = "${azurerm_resource_group.fakeonprem.name}"

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = "${azurerm_public_ip.gwip3.id}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "${azurerm_subnet.vnet3_gw.id}"
  }
}

resource "azurerm_local_network_gateway" "vnet2" {
  name                = "vnet2_localgw_to_vnet3"
  location            = "${azurerm_resource_group.cloud.location}"
  resource_group_name = "${azurerm_resource_group.cloud.name}"
  gateway_address     = "${azurerm_public_ip.gwip3.ip_address}"
  address_space       = ["172.30.1.0/24"]

}

resource "azurerm_local_network_gateway" "vnet3" {
  name                = "vnet3_localgw_to_vnet2"
  location            = "${azurerm_resource_group.fakeonprem.location}"
  resource_group_name = "${azurerm_resource_group.fakeonprem.name}"
  gateway_address     = "${azurerm_public_ip.gwip2.ip_address}"
  address_space       = ["172.22.1.0/24"]
}

resource "azurerm_virtual_network_gateway_connection" "cloud" {
  name                = "cloud2fakeonprem"
  location            = "${azurerm_resource_group.cloud.location}"
  resource_group_name = "${azurerm_resource_group.cloud.name}"

  type                       = "IPsec"
  virtual_network_gateway_id = "${azurerm_virtual_network_gateway.gw2.id}"
  local_network_gateway_id   = "${azurerm_local_network_gateway.vnet2.id}"

  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}

resource "azurerm_virtual_network_gateway_connection" "fakeonprem" {
  name                = "fakeonprem2cloud"
  location            = "${azurerm_resource_group.fakeonprem.location}"
  resource_group_name = "${azurerm_resource_group.fakeonprem.name}"

  type                       = "IPsec"
  virtual_network_gateway_id = "${azurerm_virtual_network_gateway.gw3.id}"
  local_network_gateway_id   = "${azurerm_local_network_gateway.vnet3.id}"

  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}