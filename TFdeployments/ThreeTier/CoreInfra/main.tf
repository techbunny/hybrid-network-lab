resource "azurerm_resource_group" "region1" {
  name     = "${var.region1_name}_core"
  location = var.region1_loc
  tags     = var.tags
}

resource "azurerm_resource_group" "region2" {
  name     = "${var.region2_name}_core"
  location = var.region2_loc
  tags     = var.tags
}

# Create Proximity Placement Groups

module "ppg_region1" {
  source = "../../../TFmodules/ppg"

  ppg_instance_count  = 2
  ppg_name            = "${var.region1_name}_ppg"
  location            = azurerm_resource_group.region1.location
  resource_group_name = azurerm_resource_group.region1.name
  tags                = var.tags

}

module "ppg_region2" {
  source = "../../../TFmodules/ppg"

  ppg_instance_count  = 2
  ppg_name            = "${var.region2_name}_ppg"
  location            = azurerm_resource_group.region2.location
  resource_group_name = azurerm_resource_group.region2.name
  tags                = var.tags

}

# Deploy VNETS with Default Subnets

module "vnet_region1" {
  source = "../../../TFmodules/networking/vnet"

  resource_group_name = azurerm_resource_group.region1.name
  location            = azurerm_resource_group.region1.location

  vnet_name             = "${var.region1_name}_vnet"
  address_space         = "10.1.0.0/16"
  default_subnet_prefix = "10.1.1.0/24"
  dns_servers = [
    "10.1.1.200",
    "10.1.1.201",
    "168.63.129.16"
  ]
}

module "vnet_region2" {
  source = "../../../TFmodules/networking/vnet"

  resource_group_name = azurerm_resource_group.region2.name
  location            = azurerm_resource_group.region2.location

  vnet_name             = "${var.region2_name}_vnet"
  address_space         = "10.2.0.0/16"
  default_subnet_prefix = "10.2.1.0/24"
  dns_servers = [
    "168.63.129.16"
  ]
}

# data "azurerm_lb" "lb" {
#   name                = "lb-outbound-only"
#   resource_group_name  = azurerm_resource_group.region1.name
# }

# data "azurerm_lb_backend_address_pool" "lb" {
#   name            = "${azurerm_resource_group.region1.name}-outbound-pool"
#   loadbalancer_id = data.azurerm_lb.lb.id
# }

# Peering between VNET1 and VNET2

module "peering" {
  source = "../../../TFmodules/networking/peering"

  resource_group_nameA = azurerm_resource_group.region1.name
  resource_group_nameB = azurerm_resource_group.region2.name
  netA_name            = module.vnet_region1.vnet_name
  netA_id              = module.vnet_region1.vnet_id
  netB_name            = module.vnet_region2.vnet_name
  netB_id              = module.vnet_region2.vnet_id

}

# Bastion Host

module "bastion_region1" {
  source = "../../../TFmodules/bastion"

  resource_group_name  = azurerm_resource_group.region1.name
  virtual_network_name = module.vnet_region1.vnet_name
  subnet_cidr          = "10.1.250.0/24"
  location             = var.region1_loc

}

# Log Analytics Workspace

module "log_analytics" {
  source = "../../../TFmodules/analytics"

  resource_group_name = azurerm_resource_group.region1.name
  location            = var.region1_loc
  workspace_name      = "region1workspace"
  sku                 = "PerGB2018"

}

# LB for Outbound Access

module "outbound_lb_region1" {
  source = "../../../TFmodules/loadbalancer/lb_external"

  lbname   = "lb-outbound-only"
  location = azurerm_resource_group.region1.location
  rg_name  = azurerm_resource_group.region1.name
  subnetName              = module.vnet_region1.default_subnet_name
  core_vnet_name          = module.vnet_region1.vnet_name
  core_rg_name            = azurerm_resource_group.region1.name
  compute_hostname_prefix = "${azurerm_resource_group.region1.name}-outbound"


}

# Deploy DSC Service

module "DSC_setup" {
  source = "../../../TFmodules/dsc_setup"

  location = azurerm_resource_group.region1.location
  rg_name  = azurerm_resource_group.region1.name

}

module "DSC_config" {
  source = "../../../TFmodules/dsc_configuration"

  location = azurerm_resource_group.region1.location
  rg_name  = azurerm_resource_group.region1.name

  domain_name        = "IMPERFECTLAB.COM"
  domain_user        = "IMPERFECTLAB.COM\\sysadmin"
  admin_password     = var.admin_password
  admin_username     = var.admin_username
  domain_NetbiosName = "IMPERFECTLAB"

}





