variable "ppg_name" {

}

variable "location" {
    
}

variable "resource_group_name" {

}

variable "ppg_instance_count" {

}

variable "tags" {
  type        = map(string)

  default = {
    application = "CoreCard"
  }
}

resource "azurerm_proximity_placement_group" "ppg" {
  count               = var.ppg_instance_count
  name                = "${var.ppg_name}-${format("%.02d",count.index + 1)}" 
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = var.tags
}

output "ppg_id" {
    value = azurerm_proximity_placement_group.ppg.*.id
}

