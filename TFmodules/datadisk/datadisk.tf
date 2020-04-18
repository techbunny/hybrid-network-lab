resource "azurerm_managed_disk" "datadisk" {
  count                = (var.compute_instance_count * var.disk_instance_count)
  name                 = "${var.disk_name}-${format("%.02d",count.index + 1)}-${var.disk_code_name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.data_sa_type
  disk_size_gb         = var.disk_size_gb
  create_option        = "Empty"
  zones                = var.zones

  tags = var.tags

}


resource "azurerm_virtual_machine_data_disk_attachment" "datadisk" {
  count              = var.compute_instance_count * var.disk_instance_count
  managed_disk_id    = azurerm_managed_disk.datadisk[count.index].id
  # virtual_machine_id = var.vm_id
  virtual_machine_id = element(concat(var.vm_id), count.index)
  lun                = count.index + 10
  caching            = "ReadWrite"
}


# Variables

variable "compute_instance_count" {

}
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

variable "disk_instance_count" {

}

variable "disk_code_name" {

}
