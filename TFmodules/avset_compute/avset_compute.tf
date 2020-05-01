# Create diagnostic storage account for VMs
module "create_boot_sa" {
  source  = "../storage"

  resource_group_name       = var.resource_group_name
  location                  = var.location
  tags                      = var.tags
  compute_hostname_prefix   = "winserver01"
}

resource "azurerm_availability_set" "compute" {
  name                         = "${var.compute_hostname_prefix}-avset"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = var.tags
}

# Basic VM, Wit AVSet, Windows
resource "azurerm_windows_virtual_machine" "compute" {
  count                         = var.compute_instance_count
  name                          = "${var.compute_hostname_prefix}-${format("%.02d",count.index + 1)}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  size                          = var.vm_size
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  network_interface_ids         = [element(concat(azurerm_network_interface.compute.*.id), count.index)]
  # allow_extension_operations  = 
  availability_set_id            = azurerm_availability_set.compute.id
  tags                          = var.tags
  enable_automatic_updates      = true

  os_disk {
    name              = "${var.compute_hostname_prefix}-${format("%.02d",count.index + 1)}-disk-OS"
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
    name                 = "${var.compute_hostname_prefix}-${format("%.02d",count.index + 1)}-disk-data-01"  
    count                = var.create_data_disk * var.compute_instance_count
    location             = var.location
    resource_group_name  = var.resource_group_name
    storage_account_type = var.storage_account_type
    create_option        = "Empty"
    disk_size_gb         = var.data_disk_size_gb


}

resource "azurerm_virtual_machine_data_disk_attachment" "vm_data_disks_attachment" {
  managed_disk_id    = element(azurerm_managed_disk.vm_data_disks.*.id, count.index)
  virtual_machine_id = element(azurerm_windows_virtual_machine.compute.*.id, count.index)
  lun                = count.index
  caching            = "None"
  count = var.create_data_disk
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