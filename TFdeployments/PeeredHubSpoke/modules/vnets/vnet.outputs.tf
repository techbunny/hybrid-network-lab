# output "rg_cloud" {
#     value = "${azurerm_resource_group.cloud.name}"
# }

# output "rg_cloud_location" {
#     value = "${azurerm_resource_group.cloud.location}"
# }

# output "rg_fakeonprem" {
#     value = "${azurerm_resource_group.fakeonprem.name}"
# }

# output "rg_fakeonprem_location" {
#     value = "${azurerm_resource_group.fakeonprem.location}"
# }


output "vnet1_name" {
    value = "${azurerm_virtual_network.vnet1.name}"
}

output "vnet2_name" {
    value = "${azurerm_virtual_network.vnet2.name}"
}

output "vnet3_name" {
    value = "${azurerm_virtual_network.vnet3.name}"
}

# Outputs Used by the Connection Module

# output "gw2_subnet_id" {
#     value = "${azurerm_subnet.vnet2_gw.id}"
# }

# output "gw3_subnet_id" {
#     value = "${azurerm_subnet.vnet3_gw.id}"
# }
# output "gwip3_pip_id" {
#   value = "${azurerm_public_ip.gwip3.id}"
# }

# output "gwip2_pip_id" {
#   value = "${azurerm_public_ip.gwip2.id}"
# }

# output "gwip3_pip_name" {
#   value = "${azurerm_public_ip.gwip3.name}"
# }

# output "gwip2_pip_name" {
#   value = "${azurerm_public_ip.gwip2.name}"
# }

output "vnet1_id" {
    value = "${azurerm_virtual_network.vnet1.id}"
}

output "vnet2_id" {
    value = "${azurerm_virtual_network.vnet2.id}"
}
output "vnet3_id" {
    value = "${azurerm_virtual_network.vnet3.id}"
}


# Outputs used by the Compute Module
output "vnet1_subnet_id" {
    value = "${azurerm_subnet.vnet1_default.id}"
}

output "vnet2_subnet_id" {
    value = "${azurerm_subnet.vnet2_default.id}"
}

output "vnet3_subnet_id" {
    value = "${azurerm_subnet.vnet3_default.id}"
}