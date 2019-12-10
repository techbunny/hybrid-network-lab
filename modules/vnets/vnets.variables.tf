variable "rg_name_cloud" {
    default = "xyz_rg_cloud"
   
}
variable "rg_name_fakeonprem" {
    default = "xyz_rg_fakeonprem"
   
}

# If deploying the Bastion Host, make sure the "location_cloud" variable is set to one of the following regions:
# West US, East US, West Europe, South Central US, Austrailia East and Japan East. 
variable "location_cloud" {
    default = "westus"
}
variable "location_fakeonprem" {
  default = "eastus2"
}

variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type = "map"

  default = {
    application = "networking"
  }
}

variable "vnet1_name" {
    default = "vnet1"
}

variable "address_space1" {
  default = "172.21.0.0/16"
}

variable "vnet2_name" {
    default = "vnet2"
}

variable "address_space2" {
  default = "172.22.0.0/16"
}

variable "vnet3_name" {
    default = "vnet3"
}

variable "address_space3" {
  default = "172.30.0.0/16"
}

variable "allow_virtual_network_access" {
  description = "Controls if the VMs in the remote virtual network can access VMs in the local virtual network. Defaults to false."
  default     = true
}

variable "cloud_gwip" {
  default = "0"
}

variable "fakeonprem_gwip" {
    default = "0"
}