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

  vnet_name          = "${var.region1_name}_vnet"
  address_space      = "10.1.0.0/16"
  default_subnet_prefix = "10.1.1.0/24"
}

module "vnet_region2" {
  source = "../../../TFmodules/networking/vnet"

  resource_group_name = azurerm_resource_group.region2.name
  location            = azurerm_resource_group.region2.location

  vnet_name          = "${var.region2_name}_vnet"
  address_space      = "10.2.0.0/16"
  default_subnet_prefix = "10.2.1.0/24"
}

# Peering between VNET1 and VNET2

module "peering" {
  source = "../../../TFmodules/networking/peering"

  resource_group_nameA = azurerm_resource_group.region1.name
  resource_group_nameB = azurerm_resource_group.region2.name
  netA_name      = module.vnet_region1.vnet_name
  netA_id        = module.vnet_region1.vnet_id
  netB_name      = module.vnet_region2.vnet_name
  netB_id        = module.vnet_region2.vnet_id
  
}

# Deploy VM for DC

module "create_windowsserver_region1" {
  source = "../../../TFmodules/compute"

  resource_group_name          = azurerm_resource_group.region1.name
  location                     = azurerm_resource_group.region1.location
  vnet_subnet_id               = module.vnet_region1.default_subnet_id

  tags                           = var.tags
  compute_hostname_prefix        = "DC-${var.region1_name}"
  compute_instance_count         = 1

  vm_size                        = "Standard_D2_v2"
  os_publisher                   = var.os_publisher
  os_offer                       = var.os_offer
  os_sku                         = var.os_sku
  os_version                     = var.os_version
  storage_account_type           = var.storage_account_type
  compute_boot_volume_size_in_gb = var.compute_boot_volume_size_in_gb
  admin_username                 = var.admin_username
  admin_password                 = var.admin_password
  enable_accelerated_networking  = var.enable_accelerated_networking
  boot_diag_SA_endpoint          = var.boot_diag_SA_endpoint
  create_public_ip               = 0
  create_data_disk               = 1
  assign_bepool                  = 0
  create_av_set                  = 0
}


module "create_windowsserver_region2" {
  source = "../../../TFmodules/compute"

  resource_group_name          = azurerm_resource_group.region2.name
  location                     = azurerm_resource_group.region2.location
  vnet_subnet_id               = module.vnet_region2.default_subnet_id

  tags                           = var.tags
  compute_hostname_prefix        = "DC-${var.region2_name}"
  compute_instance_count         = 1

  vm_size                        = "Standard_D2_v2"
  os_publisher                   = var.os_publisher
  os_offer                       = var.os_offer
  os_sku                         = var.os_sku
  os_version                     = var.os_version
  storage_account_type           = var.storage_account_type
  compute_boot_volume_size_in_gb = var.compute_boot_volume_size_in_gb
  admin_username                 = var.admin_username
  admin_password                 = var.admin_password
  enable_accelerated_networking  = var.enable_accelerated_networking
  boot_diag_SA_endpoint          = var.boot_diag_SA_endpoint
  create_public_ip               = 0
  create_data_disk               = 1
  assign_bepool                  = 0
  create_av_set                  = 0
}






