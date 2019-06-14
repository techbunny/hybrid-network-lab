# Deploy three VNETS

module "vnets" {
  source = "./modules/vnets"
  }

# Deploy VMs as jumpboxes

module "create_jumpbox_vnet1" {
  source = "./modules/compute"
  
  resource_group_name = module.vnets.rg_cloud
  location            = var.location_cloud
  vnet_subnet_id      = module.vnets.vnet1_subnet_id

  tags                           = var.tags
  compute_hostname_prefix        = var.compute_hostname_prefix_jumpbox
  compute_instance_count         = var.jumpbox_instance_count
  vm_size                        = var.vm_size
  os_publisher                   = var.os_publisher
  os_offer                       = var.os_offer
  os_sku                         = var.os_sku
  os_version                     = var.os_version
  storage_account_type           = var.storage_account_type
  compute_boot_volume_size_in_gb = var.jumpbox_boot_volume_size_in_gb
  admin_username                 = var.admin_username
  admin_password                 = var.admin_password
  enable_accelerated_networking  = var.enable_accelerated_networking
  boot_diag_SA_endpoint          = var.boot_diag_SA_endpoint
  create_public_ip               = 1
  create_data_disk               = 0
  assign_bepool                  = 0
  create_av_set                  = 0
}

# Deploy Windows AKS Cluster

module "aks" {
  source = "./modules/aks"

  resource_group_name = module.vnets.rg_cloud
  location            = var.location_cloud
  vnet_network_name   = module.vnets.vnet1_name
  prefix              = var.prefix
  address_prefix      = var.subnet_cidr
  kubernetes_client_id     = var.kubernetes_client_id
  kubernetes_client_secret = var.kubernetes_client_secret


}

# TODO
# LogicApps ISE
# APIM
# Application Gateway

# Domain Controllers
