# Subscription Variables

variable "tenant_id" {

}

variable "subscription_id" {

}

# variable "client_id" {

# }
# variable "client_secret" {

# }

# Core Infra Variables

variable "region1_loc" {
    default = "eastus"
}

variable "region2_loc" {
    default = "eastus2"
}

variable "region1_name" {
    default = "RegionA"
}

variable "region2_name" {
    default = "RegionB"
}

variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type        = map(string)

  default = {
    owner       = "jcroth"
  }
}


# Windows DC Variables

variable "compute_boot_volume_size_in_gb" {
  description = "Boot volume size of jumpbox instance"
  default     = 128
}

variable "enable_accelerated_networking" {
  default = "false"
}

variable "boot_diag_SA_endpoint" {
  default = "0"
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


# DSC Variables

variable dsc_config {
  default = "blank"
}

variable dsc_mode {
  default = "applyAndMonitor"
}


