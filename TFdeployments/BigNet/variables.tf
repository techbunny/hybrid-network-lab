# Base Variables 

variable "rg_name" {
}

# variable "location" {
# }


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

variable "boot_diag_SA_endpoint" {
  default = "0"
}

# variable "vm_size" {
#   default = "Standard_D2_V2"
# }


variable "os_version" {
  default = "latest"
}

variable "admin_username" {
  default = "sysadmin"
}

variable "storage_account_type" {
  default = "Standard_LRS"
}

variable regions {
  default = {
    "westus2" = "3",
    "westcentralus" = "2"
  }

}


variable hostinfo1 {
  description = "Map of VM hosts needed in VNET1"
  type        = map
  default = {
    # vm1 = {
    #   vm_size = "Standard_DC2s_v2",
    #   zone    = "1"
    # },
    vm2 = {
      vm_size = "Standard_D2_v2",
      },
    vm3 = {
      vm_size = "Standard_DS2_v2",
    },
    vm4 = {
      vm_size = "Standard_D4_v3",
    },
    vm5 = {
      vm_size = "Standard_D4s_v3",
    },
    vm6 = {
      vm_size = "Standard_D4a_v4",
    },
    vm7 = {
      vm_size = "Standard_D4as_v4",
    },
    vm8 = {
      vm_size = "Standard_D4d_v4",
    },
    vm9 = {
      vm_size = "Standard_D4ds_v4",
    },
    vm10 = {
      vm_size = "Standard_D4_v4",
    },
    vm11 = {
      vm_size = "Standard_D4s_v4",
    }
  }
}


# variable hostinfo2 {
#   description = "Map of VM hosts needed in VNET2"
#   type        = map
#   default = {
#     vm1 = {
#       vm_size = "Standard_E4s_v4",
#       zone    = "1"
#     },
#     vm2 = {
#       vm_size = "Standard_F4s_v2",
#       zone    = "2"
#     },
#     vm3 = {
#       vm_size = "Standard_L8s_v2",
#       zone    = "3"
#     }
#   }
# }



