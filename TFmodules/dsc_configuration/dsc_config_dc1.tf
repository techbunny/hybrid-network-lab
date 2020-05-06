resource "azurerm_automation_module" "ad" {
  name                    = "xActiveDirectory"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/xactivedirectory.3.0.0.nupkg"
  }
}


resource "azurerm_automation_dsc_configuration" "dsc_dc1" {
  name                    = "DC1config"
  automation_account_name = data.azurerm_automation_account.dsc.name
  location            = var.location
  resource_group_name = var.rg_name


  content_embedded = <<CONFIG
configuration DC1config
{
Import-DSCResource -ModuleName xStorage

Node "localhost"
{ 
  xWaitforDisk Disk2
  {
        DiskId = "2"
        RetryIntervalSec = 30
        RetryCount = 20
  }
  xDisk ADDataDisk2
  {
      DiskId = "2"
      DriveLetter = "F"
    DependsOn="[xWaitForDisk]Disk2"
  }

  LocalConfigurationManager
   {
       ConfigurationMode = 'ApplyAndAutoCorrect'
       RebootNodeIfNeeded = $true
       ActionAfterReboot = 'ContinueConfiguration'
       AllowModuleOverwrite = $true
   }

   WindowsFeature DNS_RSAT
   { 
       Ensure = "Present" 
       Name = "RSAT-DNS-Server"
    }

   WindowsFeature ADDS_Install 
   { 
       Ensure = 'Present' 
       Name = 'AD-Domain-Services' 
   } 

   WindowsFeature RSAT_AD_AdminCenter 
   {
       Ensure = 'Present'
       Name   = 'RSAT-AD-AdminCenter'
   }

   WindowsFeature RSAT_ADDS 
   {
       Ensure = 'Present'
       Name   = 'RSAT-ADDS'
   }

   WindowsFeature RSAT_AD_PowerShell 
   {
       Ensure = 'Present'
       Name   = 'RSAT-AD-PowerShell'
   }

   WindowsFeature RSAT_AD_Tools 
   {
       Ensure = 'Present'
       Name   = 'RSAT-AD-Tools'
   }

   WindowsFeature RSAT_Role_Tools 
   {
       Ensure = 'Present'
       Name   = 'RSAT-Role-Tools'
   }      

}
}
CONFIG
}
