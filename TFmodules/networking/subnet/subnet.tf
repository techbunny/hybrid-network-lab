resource "azurerm_subnet" "extrasubnet" {
  name                 = var.subnet_name
  resource_group_name =  var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.subnet_prefix]

}

variable "subnet_name" {
   
}

variable "subnet_prefix" {

}

variable "virtual_network_name"  {

}

variable "resource_group_name" {
    
}

output "subnet_id" {
    value = azurerm_subnet.extrasubnet.id
}