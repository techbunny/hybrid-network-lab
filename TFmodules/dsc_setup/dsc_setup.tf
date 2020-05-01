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

