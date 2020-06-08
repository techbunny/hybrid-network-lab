data "azurerm_subnet" "lbSubnet" {
  name                 = var.subnetName
  virtual_network_name = var.core_vnet_name
  resource_group_name  = var.core_rg_name
}

resource "azurerm_public_ip" "lb" {
  name                = "outbound_lb_ip"
  location            = var.location
  resource_group_name = var.core_rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  # zones                = var.zones

}

resource "azurerm_lb" "lb" {
  name                = var.lbname
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.lbname}-publicip"
    public_ip_address_id = azurerm_public_ip.lb.id
    # zones                = var.zones
  }
}

resource "azurerm_lb_backend_address_pool" "lb" {
  resource_group_name = var.rg_name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "${var.compute_hostname_prefix}-pool"

}

resource "azurerm_lb_outbound_rule" "lb" {
  resource_group_name     = var.rg_name
  loadbalancer_id         = azurerm_lb.lb.id
  name                    = "OutboundRule"
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb.id

  frontend_ip_configuration {
    name = "${var.lbname}-publicip"
  }
}

# Outputs from LB Module

output "vm_backendpool_id" {
    value = azurerm_lb_backend_address_pool.lb.id
}


# Variables for LB Module

variable "lbname" {

}
variable "location" {

}
# variable "zones" {

# }

variable "subnetName" {

}

variable "core_vnet_name" {

}

variable "rg_name"  {

}

variable "core_rg_name" {

}

variable "compute_hostname_prefix" {

}

