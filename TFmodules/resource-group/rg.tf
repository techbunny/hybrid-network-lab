resource "azurerm_resource_group" "resourcegroup" {

  name     = var.name
  location = var.location
  tags     = var.tags
}

output rg_name {
    value = azurerm_resource_group.resourcegroup.name
}

output rg_location {
    value = azurerm_resource_group.resourcegroup.location
}

output "rg_instance_location" {
   value = [
        for instance in azurerm_resource_group.resourcegroup:
        azurerm_resource_group.resourcegroup.location
    ]
}

variable "name" {

}

variable "location" {
    
}

variable "tags" {
  type = map(string)

  default = {
    project = "jumboframes"
  }
} 