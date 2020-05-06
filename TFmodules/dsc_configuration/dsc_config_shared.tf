
variable "location" {

}

variable "rg_name" {
  
}

data "azurerm_automation_account" "dsc" {
  name                = "dscautomation"
  resource_group_name = var.rg_name
  
}
