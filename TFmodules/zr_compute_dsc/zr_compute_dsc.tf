data "azurerm_proximity_placement_group" "region_ppg" {
  count               = var.compute_instance_count
  name                = "${var.region_name}_ppg-0${(count.index % 2) + 1}"
  resource_group_name = "${var.region_name}_core"
  }

# Create diagnostic storage account for VMs
module "create_boot_sa" {
  source  = "../storage"

  resource_group_name       = var.resource_group_name
  location                  = var.location
  tags                      = var.tags
  compute_hostname_prefix   = var.compute_hostname_prefix
}

# Basic VM, Zone_Redundant, Windows
resource "azurerm_virtual_machine" "compute" {

  count                         = var.compute_instance_count
  name                          = "${var.compute_hostname_prefix}-${format("%.02d",count.index + 1)}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  vm_size                       = var.vm_size
  network_interface_ids         = [element(concat(azurerm_network_interface.compute.*.id), count.index)]
  delete_os_disk_on_termination = "true"
  delete_data_disks_on_termination = "true"
  proximity_placement_group_id  = data.azurerm_proximity_placement_group.region_ppg[count.index].id 
  zones                         = ["${(count.index % 2) + 1}"]
  
  tags = var.tags

  storage_image_reference {
    publisher = var.os_publisher
    offer     = var.os_offer
    sku       = var.os_sku
    version   = var.os_version
}

  storage_os_disk {
    name              = "${var.compute_hostname_prefix}-${format("%.02d",count.index + 1)}-disk-OS"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    disk_size_gb      = 128
    managed_disk_type = var.os_sa_type
  }

  os_profile {
    computer_name  = "${var.compute_hostname_prefix}-${format("%.02d",count.index + 1)}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_windows_config {
    provision_vm_agent = true
    enable_automatic_upgrades = false
    
  }

   boot_diagnostics {
    enabled     = "true"
    storage_uri = module.create_boot_sa.boot_diagnostics_account_endpoint
  }
}

module "create_datadisks" {
  source  = "../datadisk"

  compute_instance_count    = var.compute_instance_count
   disk_instance_count       = var.p30_instance_count
  resource_group_name       = var.resource_group_name
  location                  = var.location
  tags                      = var.tags
  disk_name                 = "${var.compute_hostname_prefix}-data"
  data_sa_type              = "Premium_LRS"
  disk_size_gb              = 1024
  disk_code_name            = "P30"
  vm_id                     = azurerm_virtual_machine.compute.*.id
  vm_name                   = azurerm_virtual_machine.compute.*.name
  compute_hostname_prefix   = var.compute_hostname_prefix
  }

resource "azurerm_network_interface" "compute" {
  count                         = var.compute_instance_count
  name                          = "${var.compute_hostname_prefix}-${format("%.02d",count.index + 1)}-nic" 
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "ipconfig${count.index}"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_network_interface_backend_address_pool_association" "compute" {
  count                   = var.assign_bepool * var.compute_instance_count  
  network_interface_id    = element(azurerm_network_interface.compute.*.id, count.index)
  ip_configuration_name   = "ipconfig${count.index}"
  backend_address_pool_id = var.backendpool_id
}

resource "azurerm_network_interface_backend_address_pool_association" "outbound" {
  count                   = var.assign_bepool * var.compute_instance_count  
  network_interface_id    = element(azurerm_network_interface.compute.*.id, count.index)
  ip_configuration_name   = "ipconfig${count.index}"
  backend_address_pool_id = var.outbound_backendpool_id
}

resource "azurerm_virtual_machine_extension" "dsc" {
  count = var.compute_instance_count
  name                 = "TestDSC"
  virtual_machine_id   = element(azurerm_virtual_machine.compute.*.id, count.index)
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.80"

  settings = <<SETTINGS
        {
            "WmfVersion": "latest",
            "Privacy": {
                "DataCollection": ""
            },
            "Properties": {
                "RegistrationKey": {
                  "UserName": "PLACEHOLDER_DONOTUSE",
                  "Password": "PrivateSettingsRef:registrationKeyPrivate"
                },
                "RegistrationUrl": "${var.dsc_endpoint}",
                "NodeConfigurationName": "${var.dsc_config}",
                "ConfigurationMode": "${var.dsc_mode}",
                "ConfigurationModeFrequencyMins": 15,
                "RefreshFrequencyMins": 30,
                "RebootNodeIfNeeded": false,
                "ActionAfterReboot": "continueConfiguration",
                "AllowModuleOverwrite": false
            }
        }
    SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Items": {
        "registrationKeyPrivate" : "${var.dsc_key}"
      }
    }
PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "joindomain" {
  count = var.compute_instance_count
  name                 = "joindomain" 
  virtual_machine_id   = element(azurerm_virtual_machine.compute.*.id, count.index)
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings = <<SETTINGS
      {
        "Name": "EXAMPLE.COM",
        "User": "EXAMPLE.COM\\azureuser",
        "Restart": "true",
        "Options": "3"
      }
    SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "YourPasswordHere"
    }
PROTECTED_SETTINGS
}
