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

resource "azurerm_windows_virtual_machine_scale_set" "compute" {
  name                = var.vmss_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.vm_size
  instances           = 3
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  source_image_reference {
    publisher = var.os_publisher
    offer     = var.os_offer
    sku       = var.os_sku
    version   = var.os_version
  }

  os_disk {
    storage_account_type = var.os_sa_type
    caching              = "ReadWrite"
    disk_size_gb      = 128

  }

  boot_diagnostics {
    storage_account_uri = module.create_boot_sa.boot_diagnostics_account_endpoint
  }

  network_interface {
    name    = "${var.compute_hostname_prefix}-nic" 
    primary = true
    # network_security_group_id = 

    ip_configuration {
      name                          = "ipconfig"
      subnet_id                     = var.vnet_subnet_id
      load_balancer_backend_address_pool_ids = [var.backendpool_id, var.outbound_backendpool_id]

     }
    }

  data_disk {
      storage_account_type      = "Premium_LRS"
      disk_size_gb              = 1023
      lun                       = 11
      caching                   = "ReadWrite"
  }

    data_disk {
      storage_account_type      = "Premium_LRS"
      disk_size_gb              = 1023
      lun                       = 12
      caching                   = "ReadWrite"
  }

    data_disk {
      storage_account_type      = "Premium_LRS"
      disk_size_gb              = 1023
      lun                       = 13
      caching                   = "ReadWrite"
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "compute" {
    virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.compute.id
    name                         = "TestDCS"
    publisher                    = "Microsoft.PowerShell"
    type                         = "DSC"
    type_handler_version         = "2.80"

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
