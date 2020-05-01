data "azurerm_automation_account" "dsc" {
  name                = "dscautomation"
  resource_group_name = var.rg_name
  
}

resource "azurerm_automation_dsc_configuration" "dsc" {
  name                    = "webserver"
  automation_account_name = data.azurerm_automation_account.dsc.name
  location            = var.location
  resource_group_name = var.rg_name


  content_embedded = <<CONFIG
configuration webserver 
{
Node web-RegionA-01
{
    WindowsFeature IIS
    {
        Ensure               = 'Present'
        Name                 = 'Web-Server'
        IncludeAllSubFeature = $true
    }
}
Node web-RegionA-02
{
    WindowsFeature IIS
    {
        Ensure               = 'Present'
        Name                 = 'Web-Server'
        IncludeAllSubFeature = $true
    }
}
  Node "localhost"
{
    WindowsFeature IIS
    {
        Ensure               = 'Present'
        Name                 = 'Web-Server'
        IncludeAllSubFeature = $true
    }
}
}
CONFIG
}


variable "location" {

}

variable "rg_name" {
  
}