# Base Variables 

variable "rg_name" {
}

variable "tenant_id" {

}

variable "subscription_id" {

}

variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type        = map(string)
}

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

variable regioninfo {
  default = {
    westus2 = {
      zones = "3"
      cidr_net = "10.1.0.0"
    },
    westcentralus = {
      zones = "2"
      cidr_net = "10.2.0.0"
    },
    centralus = {
      zones = "2"
      cidr_net = "10.3.0.0"
    }
  }

}

variable vminfo {
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
    # vm3 = {
    #   vm_size = "Standard_DS2_v2",
    # },
    # vm4 = {
    #   vm_size = "Standard_D4_v3",
    # },
    # vm5 = {
    #   vm_size = "Standard_D4s_v3",
    # },
    # vm6 = {
    #   vm_size = "Standard_D4a_v4",
    # },
    # vm7 = {
    #   vm_size = "Standard_D4as_v4",
    # },
    # vm8 = {
    #   vm_size = "Standard_D4d_v4",
    # },
    # vm9 = {
    #   vm_size = "Standard_D4ds_v4",
    # },
    # vm10 = {
    #   vm_size = "Standard_D4_v4",
    # },
    # vm11 = {
    #   vm_size = "Standard_D4s_v4",
    # }
  }
}



