
	# WindowsFeature RSATWebServer
	# {
	# 	Ensure = "Present"
	# 	Name = "RSAT-Web-Server"
	# }

resource "azurerm_automation_dsc_configuration" "dsc" {
  name                    = "IISInstall"
  automation_account_name = data.azurerm_automation_account.dsc.name
  location            = var.location
  resource_group_name = var.rg_name


  content_embedded = <<CONFIG
configuration IISInstall
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

	WindowsFeature WebServer
	{
		Ensure = "Present"
		Name = "Web-WebServer"
	}

	WindowsFeature WebStaticContent
	{
		Ensure = "Present"
		Name = "Web-Static-Content"
	}

	WindowsFeature WebDefaultDoc
	{
		Ensure = "Present"
		Name = "Web-Default-Doc"
	}
	
	WindowsFeature WebDirBrowsing
	{
		Ensure = "Present"
		Name = "Web-Dir-Browsing"
	}

	WindowsFeature WebHttpErrors
	{
		Ensure = "Present"
		Name = "Web-Http-Errors"
	}

	WindowsFeature WebAppDev
	{
		Ensure = "Present"
		Name = "Web-App-Dev"
	}

	WindowsFeature WebAspNet
	{
		Ensure = "Present"
		Name = "Web-Asp-Net"
	}

	WindowsFeature WebNetExt
	{
		Ensure = "Present"
		Name = "Web-Net-Ext"
	}

	WindowsFeature WebISAPIExt
	{
		Ensure = "Present"
		Name = "Web-ISAPI-Ext"
	}

	WindowsFeature WebISAPIFilter
	{
		Ensure = "Present"
		Name = "Web-ISAPI-Filter"
	}

	WindowsFeature WebHealth
	{
		Ensure = "Present"
		Name = "Web-Health"
	}

	WindowsFeature WebHttpLogging
	{
		Ensure = "Present"
		Name = "Web-Http-Logging"
	}

	WindowsFeature WebRequestMonitor
	{
		Ensure = "Present"
		Name = "Web-Request-Monitor"
	}

	WindowsFeature WebSecurity
	{
		Ensure = "Present"
		Name = "Web-Security"
	}

	WindowsFeature WebWindowsAuth
	{
		Ensure = "Present"
		Name = "Web-Windows-Auth"
	}

	WindowsFeature WebFiltering
	{
		Ensure = "Present"
		Name = "Web-Filtering"
	}

	WindowsFeature WebMgmtTools
	{
		Ensure = "Present"
		Name = "Web-Mgmt-Tools"
	}

	WindowsFeature WebMgmtConsole
	{
		Ensure = "Present"
		Name = "Web-Mgmt-Console"
	}

	WindowsFeature WebScriptingTools
	{
		Ensure = "Present"
		Name = "Web-Scripting-Tools"
	}

	WindowsFeature WebMgmtService
	{
		Ensure = "Present"
		Name = "Web-Mgmt-Service"
	}

	WindowsFeature WebMgmtCompat
	{
		Ensure = "Present"
		Name = "Web-Mgmt-Compat"
	}

	WindowsFeature WebMetabase
	{
		Ensure = "Present"
		Name = "Web-Metabase"
	}

	WindowsFeature WebWMI
	{
		Ensure = "Present"
		Name = "Web-WMI"
	}

	WindowsFeature WebLgcyMgmtConsole
	{
		Ensure = "Present"
		Name = "Web-Lgcy-Mgmt-Console"
	}

	WindowsFeature NETFrameworkCore
	{
		Ensure = "Present"
		Name = "NET-Framework-Core"
	}

	WindowsFeature WASProcessModel
	{
		Ensure = "Present"
		Name = "WAS-Process-Model"
	}
		
	WindowsFeature WASNETEnvironment
	{
		Ensure = "Present"
		Name = "WAS-NET-Environment"
	}
	
	WindowsFeature WASConfigAPIs
	{
		Ensure = "Present"
		Name = "WAS-Config-APIs"
	}
}
}
CONFIG
}