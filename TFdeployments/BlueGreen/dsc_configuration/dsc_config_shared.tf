
variable "location" {

}

variable "rg_name" {
  
}

# data "azurerm_automation_account" "dsc" {
#   name                = "dscautomation"
#   resource_group_name = var.rg_name
  
# }

resource "azurerm_automation_module" "storage" {
  name                    = "xStorage"
  resource_group_name     = var.rg_name
  automation_account_name = "dscautomation"
  # automation_account_name = azurerm_automation_account.dsc.name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/xstorage.3.4.0.nupkg"
  }
}

resource "azurerm_automation_module" "remotefile" {
  name                    = "xPSDesiredStateConfiguration"
  resource_group_name     = var.rg_name
  automation_account_name = "dscautomation"
  # automation_account_name = azurerm_automation_account.dsc.name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/xpsdesiredstateconfiguration.9.1.0.nupkg"
  }
}

