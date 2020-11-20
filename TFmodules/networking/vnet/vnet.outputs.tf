
output "vnet_name" {
    value = azurerm_virtual_network.vnet.name
}

output "vnet_id" {
    value = azurerm_virtual_network.vnet.id
}

output "default_subnet_id" {
  value = azurerm_subnet.vnet.id
}

output "default_subnet_name" {
  value = azurerm_subnet.vnet.name
}

output "defaultsub_nsg_name" {
    value = azurerm_network_security_group.nsg.name
}

