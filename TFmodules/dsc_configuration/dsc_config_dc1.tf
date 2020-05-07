resource "azurerm_automation_module" "ad" {
  name                    = "ActiveDirectoryDsc"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/activedirectorydsc.6.0.1.nupkg"
  }
}

resource "azurerm_automation_credential" "domainadmin" {
  name                    = "domainadmin"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name
  username                = var.admin_username
  password                = var.admin_password
}

resource "azurerm_automation_credential" "safemode" {
  name                    = "safemode"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name
  username                = var.admin_username
  password                = var.admin_password

}


resource "azurerm_automation_dsc_configuration" "dsc_dc1" {
  name                    = "DC1config"
  automation_account_name = data.azurerm_automation_account.dsc.name
  location            = var.location
  resource_group_name = var.rg_name


  content_embedded = <<CONFIG
configuration DC1config
{
param
(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.PSCredential]
    $domainadmin,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.PSCredential]
    $safemode
)

Import-DSCResource -ModuleName xStorage
Import-DSCResource -ModuleName ActiveDirectoryDsc

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

   ADDomain CreateForest 
    { 
      DomainName = "${var.domain_name}"
      Credential = $domainadmin
      SafemodeAdministratorPassword = $safemode
      DomainNetbiosName = "${var.domain_NetbiosName}"
      DatabasePath = "F:\NTDS"
      LogPath =  "F:\NTDS"
      SysvolPath = "F:\SYSVOL"
      DependsOn = "[WindowsFeature]ADDS_Install"
    }

}
}
CONFIG
}


# Domain Join Variables

variable domain_name {

}

variable domain_user {

}

variable admin_password {

}

variable domain_NetbiosName {

}

variable admin_username {

}