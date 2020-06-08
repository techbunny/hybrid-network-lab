variable "resource_group_name" {

}

variable "location" {

}

variable "region_name" {

}

# DSC Variables


variable "dsc_key" {
  
}

variable "dsc_endpoint" {
  
}

variable dsc_config {
}

variable dsc_mode {
  default = "applyAndAutoCorrect"
}

variable workspace_id {

}

variable workspace_key {
  
}


# Domain Join Variables

variable domain_name {

}

variable domain_user {

}



# VM Variables

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

variable "os_sa_type" {
  default = "Standard_LRS"
}

variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type        = map(string)

  default = {
    application = "CoreCard"
  }
}

variable "compute_instance_count" {

}

variable "vnet_subnet_id" {

}

variable "compute_hostname_prefix" {

}

variable "vm_size" {
}

variable "p30_instance_count" {

}

variable "backendpool_id" {
  
}

variable "outbound_backendpool_id" {
  
}

variable "assign_bepool" {
  
}

