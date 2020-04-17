variable "disk_name" {

}

variable "location" {

}

variable "resource_group_name" {

}

variable "data_sa_type" {

}

variable "disk_size_gb" {

}

variable "tags" {
  type        = map(string)
}

variable "vm_id" {

}

variable "zones" {

}

resource "azurerm_managed_disk" "datadisk" {
  name                 = var.disk_name
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.data_sa_type
  create_option        = "Empty"
  disk_size_gb         = var.disk_size_gb
  zones                = var.zones

  tags = var.tags

}


resource "azurerm_virtual_machine_data_disk_attachment" "datadisk" {
  managed_disk_id    = azurerm_managed_disk.datadisk.id
  virtual_machine_id = var.vm_id
  lun                = "10"
  caching            = "ReadWrite"
}

