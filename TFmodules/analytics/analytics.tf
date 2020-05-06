resource "azurerm_log_analytics_workspace" "example" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = 30
}

# Variables

variable "workspace_name" {

}

variable "sku" {

}

variable "resource_group_name" {

}

variable "location" {

}