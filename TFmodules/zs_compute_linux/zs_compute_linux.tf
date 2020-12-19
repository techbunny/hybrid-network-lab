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

  count                         = var.compute_instance_count != null ? var.compute_instance_count : 1
  name                          = var.compute_instance_count != null ? "${var.compute_hostname_prefix}-z${count.index + 1}-${random_string.compute.result}-${format("%.02d",count.index + 1)}" : "${var.compute_hostname_prefix}-a${count.index + 1}-${random_string.compute.result}-${format("%.02d",count.index + 1)}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  admin_username                = var.admin_username
  size                          = var.vm_size
  network_interface_ids         = [element(concat(azurerm_network_interface.compute.*.id), count.index)]
  zone                          = var.compute_instance_count != null ? count.index + 1 : null
  availability_set_id           = null
  # availability_set_id         = var.compute_instance_count != null ? var.avset_id : null
                                         
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
  count                         = var.compute_instance_count != null ? var.compute_instance_count : 1
  # name                          = "${var.compute_hostname_prefix}-z${count.index + 1}-${random_string.compute.result}-${format("%.02d",count.index + 1)}-nic" 
  name                          = var.compute_instance_count != null ? "${var.compute_hostname_prefix}-z${count.index + 1}-${random_string.compute.result}-${format("%.02d",count.index + 1)}-nic" : "${var.compute_hostname_prefix}-a${count.index + 1}-${random_string.compute.result}-${format("%.02d",count.index + 1)}-nic"
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
  count                         = var.compute_instance_count != null ? var.compute_instance_count : 1
  # name                          = "${var.compute_hostname_prefix}-z${count.index + 1}-${random_string.compute.result}-${format("%.02d",count.index + 1)}-pip" 
  name                          = var.compute_instance_count != null ? "${var.compute_hostname_prefix}-z${count.index + 1}-${random_string.compute.result}-${format("%.02d",count.index + 1)}-pip" : "${var.compute_hostname_prefix}-a${count.index + 1}-${random_string.compute.result}-${format("%.02d",count.index + 1)}-pip"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  allocation_method             = "Static"
  zones = var.compute_instance_count != null ? [count.index + 1] : null
  sku                           = "Standard"

  tags = var.tags

}

resource "azurerm_virtual_machine_extension" "compute" {
  count                = var.compute_instance_count != null ? var.compute_instance_count : 1
  name                 = "${var.compute_hostname_prefix}-z${count.index + 1}-${random_string.compute.result}-${format("%.02d",count.index + 1)}"
  virtual_machine_id   = element(azurerm_linux_virtual_machine.compute.*.id, count.index)
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "hostname && uptime"
    }
SETTINGS


  tags = {
    environment = "Production"
  }
}

## Need to add in resource for AVSet creation if zones aren't used