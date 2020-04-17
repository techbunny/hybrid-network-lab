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

variable "region1" {
    default = "eastus"
}

variable "region2" {
    default = "centralus"
}

variable "region1_name" {
    default = "Region1_FrontEnd"
}

variable "region2_name" {
    default = "Region2_FrontEnd"
}


variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type        = map(string)

  default = {
    application = "CoreCard"
  }
}

# Web Server Variables


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

