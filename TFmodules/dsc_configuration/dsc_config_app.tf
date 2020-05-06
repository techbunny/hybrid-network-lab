resource "azurerm_automation_dsc_configuration" "dsc_disk" {
  name                    = "DiskAttach"
  automation_account_name = data.azurerm_automation_account.dsc.name
  location            = var.location
  resource_group_name = var.rg_name


  content_embedded = <<CONFIG
configuration DiskAttach
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
  xDisk DataDisk2
  {
      DiskId = "2"
      DriveLetter = "F"
    DependsOn="[xWaitForDisk]Disk2"
  }

  xWaitforDisk Disk3
  {
        DiskId = "3"
        RetryIntervalSec = 30
        RetryCount = 20
  }
  xDisk DataDisk3
  {
      DiskId = "3"
      DriveLetter = "G"
    DependsOn="[xWaitForDisk]Disk3"
  }

}
}
CONFIG
}
