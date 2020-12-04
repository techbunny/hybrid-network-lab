# Create diagnostic storage account for VMs
module "create_boot_sa" {
  source  = "../storage"

  resource_group_name       = var.resource_group_name
  location                  = var.location
  tags                      = var.tags
  compute_hostname_prefix   = var.compute_hostname_prefix
}

resource "random_string" "compute" {
  length  = 4
  special = false
  upper   = false
  number  = true
}

# Basic Linux, Single Zone
resource "azurerm_linux_virtual_machine" "compute" {

  count                         = var.compute_instance_count
  name                          = "${var.compute_hostname_prefix}-z${count.index + 1}-${random_string.compute.result}-${format("%.02d",count.index + 1)}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  admin_username                = var.admin_username
  size                          = var.vm_size
  network_interface_ids         = [element(concat(azurerm_network_interface.compute.*.id), count.index)]
  # proximity_placement_group_id  = data.azurerm_proximity_placement_group.region_ppg[count.index].id 
  zone                          = count.index + 1
                                          
  
  tags = var.tags  

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
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

resource "azurerm_network_interface" "compute" {
  count                         = var.compute_instance_count
  name                          = "${var.compute_hostname_prefix}-z${count.index + 1}-${random_string.compute.result}-${format("%.02d",count.index + 1)}-nic" 
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "ipconfig${count.index}"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.compute.*.id, count.index)
  }

  tags = var.tags
}

resource "azurerm_public_ip" "compute" {
  count                         = var.compute_instance_count
  name                          = "${var.compute_hostname_prefix}-z${count.index + 1}-${random_string.compute.result}-${format("%.02d",count.index + 1)}-pip" 
  location                      = var.location
  resource_group_name           = var.resource_group_name
  allocation_method             = "Static"
  zones                         = [count.index + 1]
  sku                           = "Standard"

  tags = var.tags

}