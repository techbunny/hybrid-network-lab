
variable "resource_group_name" {
}
variable "location" {
}
variable "tags" {
  type = map(string)

  default = {
    application = "compute"
  }
}
variable "compute_hostname_prefix" {
  description = "Prefix for naming of each VM specific resource"
}
# variable "compute_instance_count" {
#   description = "Application instance count"
# }


variable "vm_size" {
}
variable "os_publisher" {
}
variable "os_offer" {
}
variable "os_sku" {
}
variable "os_version" {

}
variable "storage_account_type" {
}
variable "compute_boot_volume_size_in_gb" {
  description = "Boot volume size of compute instance"
}
variable "data_disk_size_gb" {
    default = 128
}
variable "data_sa_type" {
    default = "Standard_LRS"
}
variable "admin_username" {
}
variable "admin_password" {
}
variable "enable_accelerated_networking" {
}
variable "vnet_subnet_id" {
}


variable "boot_diag_SA_endpoint" {

  description = "Blob endpoint for storage account to use for VM Boot diagnostics"

  type = string

}
variable "backendpool_id" {
  default = "0"
}

variable "public_ip_address_allocation" {
   default = "Static"
}
variable "ip_sku" {
    default = "Standard"
}
# variable "create_data_disk" {

# }
# variable "assign_bepool" {

# }

variable "static_ip_address" {

}


variable "outbound_backendpool_id" {

}


variable "avset_id" {
  
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

# Monitoring

variable workspace_id {

}

variable workspace_key {
  
}