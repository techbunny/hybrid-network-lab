resource "azurerm_api_management_product" "injestion" {
  product_id            = "imageingestion"
  api_management_name   = var.apim_name
  resource_group_name   = var.rg_name
  display_name          = "Image Ingestion"
  subscription_required = true
  subscriptions_limit   = 1
  approval_required     = true
  published             = true
}

resource "azurerm_api_management_group" "create_group" {
  name                = "iot-cameras"
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
  display_name        = "IoT Camera Devices"
  description         = "Camera Sensors that will be taking pictures."
}

resource "azurerm_api_management_product_group" "access_control" {
  product_id          = azurerm_api_management_product.injestion.product_id
  group_name          = azurerm_api_management_group.create_group.name
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
}

resource "azurerm_api_management_product_api" "connect_api" {
  api_name            = var.api_name
  product_id          = azurerm_api_management_product.injestion.product_id
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
}

