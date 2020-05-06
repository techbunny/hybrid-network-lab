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
  upgrade_mode        = "Automatic"
  health_probe_id     = var.health_probe_id

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

  automatic_os_upgrade_policy {
    disable_automatic_rollback = true
    enable_automatic_os_upgrade = true
  }

  rolling_upgrade_policy {
    max_batch_instance_percent = "50"
    max_unhealthy_instance_percent = "50"
    max_unhealthy_upgraded_instance_percent = "50"
    pause_time_between_batches = "PT10M"
  }

  boot_diagnostics {
    storage_account_uri = module.create_boot_sa.boot_diagnostics_account_endpoint
  }

  network_interface {
    name    = "${var.compute_hostname_prefix}-nic" 
    primary = true

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

resource "azurerm_virtual_machine_scale_set_extension" "joindomain" {
  count = var.compute_instance_count
  name                 = "joindomain" 
  virtual_machine_scale_set_id   = azurerm_windows_virtual_machine_scale_set.compute.id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings = <<SETTINGS
      {
        "Name": "${var.domain_name}",
        "User": "${var.domain_name}\\${var.admin_username}",
        "Restart": "true",
        "Options": "3"
      }
    SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${var.admin_password}"
    }
PROTECTED_SETTINGS
}
