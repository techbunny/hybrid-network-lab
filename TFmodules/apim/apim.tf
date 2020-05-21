variable "location" {

}

variable "apim_name" {

}

variable "rg_name" {

}


resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = var.location
  resource_group_name = var.rg_name
  publisher_name      = "CET"
  publisher_email     = "jcroth@microsoft.com"
  virtual_network_type  = "Internal"

  sku_name = "Premium_10"
  
  virtual_network_configuration {
    subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }
}

# resource "azurerm_api_management_user" "apim_test_user" {
#   api_management_name = "${azurerm_api_management.monster_apim.name}"
#   resource_group_name = var.rg_name
#   user_id = "123"
#   first_name = "Testman"
#   last_name = "Testmanson"
#   email = "timreilly@live.com"
#   password = "Password1234!"
#   state = "active"  
# }

# output "ocp-key" {
#   value = "${azurerm_api_management_user.apim_test_user.password}"
# }

# output "apim_url" {
#   value = "${azurerm_api_management.monster_apim.gateway_url}"
# } 

# module "apis" {
#   source = "./modules/apim/apis"

#   rg_name   = "${azurerm_resource_group.monster_rg.name}"
#   apim_name = "${azurerm_api_management.monster_apim.name}"
#   storage_host = "${azurerm_storage_account.monster_blob_storage.primary_blob_endpoint}"
# }


# module "apim_product" {
#   source = "./modules/apim/product"

#   rg_name   = "${azurerm_resource_group.monster_rg.name}"
#   apim_name = "${azurerm_api_management.monster_apim.name}"
#   api_name  = "${module.apis.api_name}"

# }


# data "azurerm_api_management" "principal_id" {
#   name                = "${azurerm_api_management.monster_apim.name}"
#   resource_group_name = "${azurerm_resource_group.monster_rg.name}"
#   depends_on          = [azurerm_api_management.monster_apim]
# }
