variable "rg_name_cloud" {
  default = "set_in_vnet.variables.tf"
}

variable "rg_name_fakeonprem" {
  default = "set_in_vnet.variables.tf"
}

variable "location_cloud" {
}

variable "location_fakeonprem" {
}

variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type        = map(string)

  default = {
    application = "vms"
  }
}

variable "compute_hostname_prefix_jumpbox" {
  description = "Application server host resource prefix"
  default     = "jumpbox"
}

variable "jumpbox_instance_count" {
  description = "jumpbox instance count"
  default     = 1
}

variable "jumpbox_boot_volume_size_in_gb" {
  description = "Boot volume size of jumpbox instance"
  default     = 128
}

# VM Image Variables 

variable "enable_accelerated_networking" {
  default = "false"
}

variable "boot_diag_SA_endpoint" {
  default = "0"
}

variable "vm_size" {
  default = "Standard_D2_V2"
}

variable "os_offer" {
  default = "WindowsServer"
}

variable "os_publisher" {
  default = "MicrosoftWindowsServer"
}

variable "os_sku" {
  default = "2019-Datacenter"
}

variable "os_version" {
  default = "latest"
}

variable "admin_username" {
  default = "sysadmin"
}

variable "admin_password" {
}

variable "storage_account_type" {
  default = "Standard_LRS"
}

# AKS Variables

variable "prefix" {
  default = "abc-rg-aks"
}

variable "subnet_cidr" {
  default = "172.21.128.0/18"
}

variable "kubernetes_client_id" {

}

variable "kubernetes_client_secret" {

}