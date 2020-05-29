# Deployment Variables

variable "event_grid_sub_name" {
}

variable "service_bus_name" {
}

variable "rg_name" {

}
variable "apim_name" {

}
variable "storage_name" {

}
variable "location" {

}

variable "subnet_id" {
  
}

resource "azurerm_resource_group" "apim_rg" {
  name     = "${var.rg_name}-apim"
  location = var.location
}


# APIM
resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = azurerm_resource_group.apim_rg.location
  resource_group_name = azurerm_resource_group.apim_rg.name
  publisher_name      = "PublisherName"
  publisher_email     = "jcroth@microsoft.com"
  virtual_network_type = "Internal"
  virtual_network_configuration {
    subnet_id = var.subnet_id
  }

  sku_name = "Premium_10"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_api_management_user" "apim_test_user" {
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.apim_rg.name
  user_id = "123"
  first_name = "Testman"
  last_name = "Testmanson"
  email = "jkcrothers@hotmail.com"
  password = "Password1234!"
  state = "active"  
}

output "ocp-key" {
  value = "${azurerm_api_management_user.apim_test_user.password}"
}

output "apim_url" {
  value = "${azurerm_api_management.apim.gateway_url}"
} 

module "apis" {
  source = "./apis"

  rg_name   = azurerm_api_management.apim.resource_group_name
  apim_name = azurerm_api_management.apim.name
  storage_host = azurerm_storage_account.blob_storage.primary_blob_endpoint

}


module "apim_product" {
  source = "./apim_product"

  rg_name   = azurerm_resource_group.apim_rg.name
  apim_name = azurerm_api_management.apim.name
  api_name  = module.apis.api_name

}


data "azurerm_api_management" "principal_id" {
  name                = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.apim_rg.name
  depends_on          = [azurerm_api_management.apim]
}

# The ability to set this role assignment (giving APIM data owner on the storage account)
# may not be granted to the service principal you are using to deploy this template. 
# If you see a error message, please review the documentation on how to create a custom role.

# resource "azurerm_role_assignment" "apim_to_storage" {
#   scope                = azurerm_storage_account.blob_storage.id
#   role_definition_name = "Storage Blob Data Owner"
#   principal_id         = azurerm_api_management.apim.identity[0].principal_id
#   depends_on           = [data.azurerm_api_management.principal_id]
# }

module "event_grid" {
  source = "./event_grid"

  event_grid_sub_name  = var.event_grid_sub_name
  rg_name              = azurerm_resource_group.apim_rg.name
  storage_account_name = azurerm_storage_account.blob_storage.name
  sb_queue_id          = azurerm_servicebus_queue.sb_queue.id
}


# Storage Account and Containers for Images
resource "azurerm_storage_account" "blob_storage" {
  name                     = var.storage_name
  location                 = azurerm_resource_group.apim_rg.location
  resource_group_name      = azurerm_resource_group.apim_rg.name
  account_kind             = "BlockBlobStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "blob_container_images" {
  name                  = "images"
  storage_account_name  = azurerm_storage_account.blob_storage.name
  container_access_type = "private"
}


# Service Bus 

resource "azurerm_servicebus_namespace" "sb_namespace" {
  name                = var.service_bus_name
  location            = azurerm_resource_group.apim_rg.location
  resource_group_name = azurerm_resource_group.apim_rg.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "sb_queue" {
  name                = "${var.service_bus_name}_queue"
  resource_group_name = azurerm_resource_group.apim_rg.name
  namespace_name      = azurerm_servicebus_namespace.sb_namespace.name

  enable_partitioning = true
}
