# Create diagnostic storage account for VMs
module "create_boot_sa" {
  source  = "../storage"

  resource_group_name       = var.resource_group_name
  location                  = var.location
  tags                      = var.tags
  compute_hostname_prefix   = "winserver01"
}

data "azurerm_proximity_placement_group" "region1_ppg" {
  name                = "Region1_ppg"
  resource_group_name = "Region1_Core"
}

data "azurerm_proximity_placement_group" "region2_ppg" {
  name                = "Region2_ppg"
  resource_group_name = "Region2_Core"
}

# Basic VM, Zonal, Windows
resource "azurerm_virtual_machine" "compute" {
  # count                         = var.compute_instance_count
  # name                          = "${var.compute_hostname_prefix}-${format("%.02d",count.index + 1)}"
  name                          = "${var.compute_hostname_prefix}-01"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  vm_size                       = var.vm_size
  network_interface_ids         = [azurerm_network_interface.compute.id]
  # network_interface_ids         = [element(concat(azurerm_network_interface.compute.*.id), count.index)]
  delete_os_disk_on_termination = "true"
  delete_data_disks_on_termination = "true"
  proximity_placement_group_id  = data.azurerm_proximity_placement_group.region1_ppg.id
  zones                         = [var.zones]
  tags = var.tags

  storage_image_reference {
    publisher = var.os_publisher
    offer     = var.os_offer
    sku       = var.os_sku
    version   = var.os_version
}

  storage_os_disk {
    # name              = "${var.compute_hostname_prefix}-${format("%.02d",count.index + 1)}-disk-OS"
    name              = "${var.compute_hostname_prefix}-disk-OS"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    disk_size_gb      = 128
    managed_disk_type = var.os_sa_type
  }

  os_profile {
    computer_name  = "${var.compute_hostname_prefix}-01"
    # computer_name  = "${var.compute_hostname_prefix}-${format("%.02d",count.index + 1)}"
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

module "create_datadisk" {
  source  = "../datadisk"

  resource_group_name       = var.resource_group_name
  location                  = var.location
  tags                      = var.tags
  disk_name                 = "${var.compute_hostname_prefix}-data-disk"
  # disk_name                 = "${var.compute_hostname_prefix}-${format("%.02d",count.index + 1)}-data-disk"
  data_sa_type              = "Premium_LRS"
  disk_size_gb              = 1024
  vm_id                     = azurerm_virtual_machine.compute.id
  zones                     = [var.zones]

}


# resource "azurerm_managed_disk" "vm_data_disks" {
#     name                 = "${var.compute_hostname_prefix}-${format("%.02d",count.index + 1)}-disk-data-01"  
#     location             = var.location
#     resource_group_name  = var.resource_group_name
#     storage_account_type = var.storage_account_type
#     create_option        = "Empty"
#     disk_size_gb         = var.data_disk_size_gb
#     count                = var.create_data_disk

# }

# resource "azurerm_virtual_machine_data_disk_attachment" "vm_data_disks_attachment" {
#   managed_disk_id    = element(azurerm_managed_disk.vm_data_disks.*.id, count.index)
#   virtual_machine_id = element(azurerm_virtual_machine.compute.*.id, count.index)
#   lun                = count.index
#   caching            = "None"
#   count = var.create_data_disk
# }

resource "azurerm_network_interface" "compute" {
  #count                         = ((var.compute_instance_count) * (1 - var.create_public_ip))
  # count                         = var.compute_instance_count
 # name                          = "${var.compute_hostname_prefix}-${format("%.02d",count.index + 1)}-nic" 
  name                          = "${var.compute_hostname_prefix}-nic"   
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "ipconfig"
    # name                          = "ipconfig${count.index}"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# resource "azurerm_network_interface" "compute_public" {
#   count                         = var.compute_instance_count * var.create_public_ip
#   name                          = "${var.compute_hostname_prefix}-${format("%.02d",count.index + 1)}-nic"  
#   location                      = var.location
#   resource_group_name           = var.resource_group_name
#   enable_accelerated_networking = var.enable_accelerated_networking

#   ip_configuration {
#     name                          = "ipconfig${count.index}"
#     subnet_id                     = var.vnet_subnet_id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = element(azurerm_public_ip.compute.*.id, count.index)
#   }

#   tags = var.tags
# }

# resource "azurerm_public_ip" "compute" {
#   name                         = "${var.compute_hostname_prefix}-${format("%.02d",count.index + 1)}-public-ip"
#   count                        = var.compute_instance_count * var.create_public_ip
#   location                     = var.location
#   resource_group_name          = var.resource_group_name
#   allocation_method            = var.public_ip_address_allocation
#   tags                         = var.tags
#   sku                          = var.ip_sku
# }

# resource "azurerm_network_interface_backend_address_pool_association" "compute" {
#   count                   = var.assign_bepool * var.compute_instance_count  
#   network_interface_id    = element(azurerm_network_interface.compute.*.id, count.index)
#   ip_configuration_name   = "ipconfig${count.index}"
#   backend_address_pool_id = var.backendpool_id
# }