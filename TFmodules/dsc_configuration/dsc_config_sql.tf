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

resource "azurerm_automation_module" "sqlserver" {
  name                    = "sqlserverdsc"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/sqlserverdsc.13.5.0.nupkg"
  }
}

