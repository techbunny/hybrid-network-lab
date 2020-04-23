resource "azurerm_resource_group" "dsc" {
  name     = "dsc-test"
  location = "eastus"
}

resource "azurerm_automation_account" "dsc" {
  name                = "dscautomation"
  location            = azurerm_resource_group.dsc.location
  resource_group_name = azurerm_resource_group.dsc.name
  sku_name = "Basic"
  
}

resource "azurerm_automation_dsc_configuration" "dsc" {
  name                    = "testconfig"
  resource_group_name     = azurerm_resource_group.dsc.name
  automation_account_name = azurerm_automation_account.dsc.name
  location                = azurerm_resource_group.dsc.location
  content_embedded        = "testconfig {}"
}