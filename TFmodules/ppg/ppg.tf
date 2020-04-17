variable "ppg_name" {

}

variable "location" {
    
}

variable "resource_group_name" {

}

variable "tags" {
  type        = map(string)

  default = {
    application = "CoreCard"
  }
}

resource "azurerm_proximity_placement_group" "ppg" {
  name                = var.ppg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = var.tags
}

output "ppg_id" {
    value = azurerm_proximity_placement_group.ppg.id
}

