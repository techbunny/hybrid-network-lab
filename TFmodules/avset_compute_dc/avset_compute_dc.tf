# Create diagnostic storage account for VMs
module "create_boot_sa" {
  source  = "../storage"

  resource_group_name       = var.resource_group_name
  location                  = var.location
  tags                      = var.tags
  compute_hostname_prefix   = "winserver01"
}


# Basic VM, Wit AVSet, Windows
resource "azurerm_windows_virtual_machine" "compute" {
  name                          = var.compute_hostname_prefix
  location                      = var.location
  resource_group_name           = var.resource_group_name
  size                          = var.vm_size
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  network_interface_ids         = [azurerm_network_interface.compute.id]
  # allow_extension_operations  = 
  availability_set_id            = var.avset_id
  tags                          = var.tags
  enable_automatic_updates      = true

  os_disk {
    name              = "${var.compute_hostname_prefix}-disk-OS"
    #create_option        = "FromImage"
    caching              = "ReadWrite"
    disk_size_gb      = var.compute_boot_volume_size_in_gb
    storage_account_type = var.storage_account_type
  }

  source_image_reference {
    publisher = var.os_publisher
    offer     = var.os_offer
    sku       = var.os_sku
    version   = var.os_version
  }

  boot_diagnostics {
    storage_account_uri = module.create_boot_sa.boot_diagnostics_account_endpoint
  }

}

resource "azurerm_managed_disk" "vm_data_disks" {
    name                 = "${var.compute_hostname_prefix}-disk-data-01"  
    location             = var.location
    resource_group_name  = var.resource_group_name
    storage_account_type = var.storage_account_type
    create_option        = "Empty"
    disk_size_gb         = var.data_disk_size_gb


}

resource "azurerm_virtual_machine_data_disk_attachment" "vm_data_disks_attachment" {
  managed_disk_id    = azurerm_managed_disk.vm_data_disks.id
  virtual_machine_id = azurerm_windows_virtual_machine.compute.id
  lun = 10
  caching            = "None"
}

resource "azurerm_network_interface" "compute" {
  name                          = "${var.compute_hostname_prefix}-nic"  
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.static_ip_address
  }

  tags = var.tags
}

resource "azurerm_network_interface_backend_address_pool_association" "outbound" {
  network_interface_id    = azurerm_network_interface.compute.id
  ip_configuration_name   = "ipconfig"
  backend_address_pool_id = var.outbound_backendpool_id
}


resource "azurerm_virtual_machine_extension" "dsc" {
  name                 = "DSConboard"
  virtual_machine_id   = azurerm_windows_virtual_machine.compute.id
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
                "RebootNodeIfNeeded": true,
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
