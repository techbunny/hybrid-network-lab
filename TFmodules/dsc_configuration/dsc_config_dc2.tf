resource "azurerm_automation_dsc_configuration" "dsc_dc2" {
  name                    = "DC2config"
  automation_account_name = data.azurerm_automation_account.dsc.name
  location            = var.location
  resource_group_name = var.rg_name


  content_embedded = <<CONFIG
configuration DC2config
{

param
(
    [System.Management.Automation.PSCredential]
    $safemode,

    [System.Management.Automation.PSCredential]
    $domainlogin
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

   WaitForADDomain WaitForestAvailability
    {
        DomainName = "${var.domain_name}"
        Credential = $domainlogin

        DependsOn  = '[WindowsFeature]RSAT_AD_PowerShell'
    }

   ADDomainController AddDC
    { 
        DomainName = "${var.domain_name}"
        Credential = $domainlogin
        SafemodeAdministratorPassword = $safemode
        DatabasePath = "F:\NTDS"
        LogPath =  "F:\NTDS"
        SysvolPath = "F:\SYSVOL"
        DependsOn = '[WaitForADDomain]WaitForestAvailability'
    }

}
}
CONFIG
}

