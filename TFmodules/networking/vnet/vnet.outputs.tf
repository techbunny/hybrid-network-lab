
output "vnet_name" {
    value = azurerm_virtual_network.vnet.name
}

output "vnet_id" {
    value = azurerm_virtual_network.vnet.id
}

# output "default_subnet_id" {
#   value = data.azurerm_virtual_network.vnet.subnets[0]
# }

output "default_subnet_id" {
  value = azurerm_subnet.vnet.id
}

