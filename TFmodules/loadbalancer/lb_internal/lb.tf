data "azurerm_subnet" "lbSubnet" {
  name                 = var.subnetName
  virtual_network_name = var.core_vnet_name
  resource_group_name  = var.core_region_name
}

resource "azurerm_lb" "lb" {
  name                = var.lbname
  location            = var.location
  resource_group_name = var.region_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.lbname}-privateip"
    subnet_id            = data.azurerm_subnet.lbSubnet.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version = "IPv4"
    # zones                = [var.zones]
  }
}

resource "azurerm_lb_backend_address_pool" "lb" {
  resource_group_name = var.region_name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "${var.compute_hostname_prefix}-pool"
}

# Outputs from LB Module

output "app_backendpool_id" {
    value = azurerm_lb_backend_address_pool.lb.id
}

output "loadbalancer_id" {
  value = azurerm_lb.lb.id
}

output "frontend_name" {
  value = azurerm_lb.lb.frontend_ip_configuration[0].name
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

variable "region_name"  {

}

variable "core_region_name" {

}

variable "compute_hostname_prefix" {

}

