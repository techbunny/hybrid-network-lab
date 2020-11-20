resource "azurerm_automation_account" "dsc" {
  name                = "dscautomation"
  location            = var.location
  resource_group_name = var.rg_name
  sku_name = "Basic"
  
}

variable "rg_name" {

}

variable "location" {
  
}

# Outputs from DSC Module

output "dsc_key" {
    value = azurerm_automation_account.dsc.dsc_primary_access_key
}

output "dsc_endpoint" {
    value = azurerm_automation_account.dsc.dsc_server_endpoint
}

output "dsc_name" {
    value = azurerm_automation_account.dsc.name
}

