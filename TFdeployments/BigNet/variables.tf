# EDIT AS NEEDED #
# Set the details for all the regions needed
# with the appropriate CIDR (/16) 

variable regioninfo {
  default = {
    westus2 = {
      zones = "3"
      cidr_net = "10.1.0.0"
    },
    eastus2 = {
      zones = "2"
      cidr_net = "10.2.0.0"
    },
    centralus = {
      zones = "2"
      cidr_net = "10.3.0.0"
    }
  }


# Base Variables 

variable "rg_name" {
}

variable "rg_location" {
}

variable "tenant_id" {
}

variable "subscription_id" {
}

variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type        = map(string)
}

# Variables for the VM deployment 

variable "boot_diag_SA_endpoint" {
  default = "0"
}

variable "os_version" {
  default = "latest"
}

variable "admin_username" {
  default = "sysadmin"
}

variable "storage_account_type" {
  default = "Standard_LRS"
}

variable "regions_with_sizes" {
  default = "westus2"
}

}

