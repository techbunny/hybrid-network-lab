resource "azurerm_lb_rule" "http" {
  resource_group_name            = var.rg_name
  loadbalancer_id                = var.lb_id
  name                           = "http-LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = var.frontend_name
  backend_address_pool_id        = var.backend_address_pool_id
  probe_id                       = azurerm_lb_probe.http.id

}

resource "azurerm_lb_probe" "http" {
  resource_group_name            = var.rg_name
  loadbalancer_id                = var.lb_id
  name                           = "http-probe"
  port                           = 80
}

variable "rg_name" {

}
variable "lb_id" {

}
variable "frontend_name" {
 
}
variable "backend_address_pool_id" {

}

# Outputs from LB Module

output "probe_id" {
    value = azurerm_lb_probe.http.id
}
