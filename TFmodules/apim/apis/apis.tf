## Main API Settings

# data "azurerm_api_management" "apim" {
#   name                = var.apim_name
#   resource_group_name = var.rg_name
# }

resource "azurerm_api_management_api" "monster_ingestion" {
  name                = "monster-ingestion"
  resource_group_name = var.rg_name
  api_management_name = var.apim_name
  revision            = "1"
  display_name        = "Put Photos Here"
  path                = "" #??
  protocols           = ["https"]
  service_url         = var.storage_host
}

resource "azurerm_api_management_api_operation" "put_to_blob" {
  operation_id        = "puttoblob"
  api_name            = azurerm_api_management_api.monster_ingestion.name
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
  display_name        = "put_to_blob"
  method              = "PUT"
  url_template        = "/images"
  description         = "This can only be done by the logged in user."

  response {
    status_code = 200
  }
}


## Operation Policies

# data "local_file" "monster-apim-policy" {
#   # filename = "./../monster_apim_policy.xml"
#   filename = "./../monster_policy.xml"
# }

# resource "azurerm_api_management_api_operation_policy" "inbound-processing" {
#   api_name            = azurerm_api_management_api.monster_ingestion.name
#   api_management_name = var.apim_name
#   resource_group_name = var.rg_name
#   operation_id        = azurerm_api_management_api_operation.put_to_blob.operation_id

#   xml_content = data.local_file.monster-apim-policy.content
# }

# data "azurerm_api_management_product" "product_creation" {
#   product_id          = "Unlimited"
#   api_management_name = data.azurerm_api_management.apim.name
#   resource_group_name = data.azurerm_api_management.apim.resource_group_name
# }



