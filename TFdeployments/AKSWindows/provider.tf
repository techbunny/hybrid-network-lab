provider "azurerm" {
  version         = ">=2.3.0"
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  features {}
}

provider "random" {
  version = ">=2.0"
}
