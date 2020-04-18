# Subscriptin Variables

variable "tenant_id" {

}

variable "subscription_id" {

}

variable "client_id" {

}
variable "client_secret" {

}

# Core Infra Variables

variable "region" {
    default = "eastus"
}

variable "region_name" {
    default = "Region1_FrontEnd"
}

variable "region_ppg" {
   default = "EastUS_ppg"
}

variable "core_region_name" {
  default = "EastUS_Core"
}

variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type        = map(string)

  default = {
    CET = "Jennelle"
  }
}

# Web Server Variables


variable "compute_boot_volume_size_in_gb" {
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

