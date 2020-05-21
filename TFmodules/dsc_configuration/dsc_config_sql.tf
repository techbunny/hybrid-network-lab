
variable "location" {

}

variable "rg_name" {
  
}

data "azurerm_automation_account" "dsc" {
  name                = "dscautomation"
  resource_group_name = var.rg_name
  
}

resource "azurerm_automation_module" "compmgmt" {
  name                    = "ComputerManagementdsc"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/computermanagementdsc.8.2.0.nupkg"
  }
}

resource "azurerm_automation_module" "failover" {
  name                    = "xFailOverCluster"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/xfailovercluster.1.14.1.nupkg"
  }
}

resource "azurerm_automation_module" "reboot" {
  name                    = "xPendingReboot"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/xpendingreboot.0.4.0.nupkg"
  }
}

resource "azurerm_automation_module" "storagedsc" {
  name                    = "Storagedsc"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/storagedsc.5.0.0.nupkg"
  }
}

resource "azurerm_automation_module" "securitypolicy" {
  name                    = "SecurityPolicydsc"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/securitypolicydsc.3.0.0-preview0002.nupkg"
  }
}

resource "azurerm_automation_module" "sqlserver" {
  name                    = "sqlserverdsc"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/sqlserverdsc.13.5.0.nupkg"
  }
}

