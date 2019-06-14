output "rg_cloud" {
    value = "${azurerm_resource_group.cloud.name}"
}

output "rg_fakeonprem" {
    value = "${azurerm_resource_group.fakeonprem.name}"
}

output "vnet1_subnet_id" {
    value = "${azurerm_subnet.vnet1_default.id}"
}

output "vnet1_name" {
    value = "${azurerm_virtual_network.vnet1.name}"
}