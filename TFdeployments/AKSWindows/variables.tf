# Base Variables 

variable "rg_name" {
}

variable "location" {
}

variable "tenant_id" {

}

variable "subscription_id" {

}

# variable "client_id" {

# }
# variable "client_secret" {

# }

variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type        = map(string)
}


# variable "compute_boot_volume_size_in_gb" {
#   description = "Boot volume size of jumpbox instance"
#   default     = 128
# }

# variable "enable_accelerated_networking" {
#   default = "true"
# }

# variable "boot_diag_SA_endpoint" {
#   default = "0"
# }

# variable "vm_size" {
#   default = "Standard_D2_V2"
# }


# variable "os_version" {
#   default = "latest"
# }

# variable "admin_username" {
#   default = "sysadmin"
# }

# variable "storage_account_type" {
#   default = "Standard_LRS"
# }
