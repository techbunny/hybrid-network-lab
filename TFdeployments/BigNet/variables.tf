
# EDIT AS NEEDED - List all the VM sizes you want deployed here. #
variable vm_sizes {
  type = list(string)
  default = [
    # "Standard_DC1s_v2", #Gen2 only
    "Standard_D2_v2",
    # "Standard_DS2_v2",
    # "Standard_D4_v3",
    # "Standard_D4s_v3",
    # "Standard_D4a_v4",
    # "Standard_D4as_v4",
    # "Standard_D4d_v4",
    # "Standard_D4ds_v4",no
    # "Standard_D4_v4",
    # "Standard_D11_v2",
    # "Standard_DS11_v2",
    # "Standard_F4s_v2",
    # "Standard_E4_v3",
    # "Standard_E4s_v3",
    # "Standard_E4a_v4",
    # "Standard_E4as_v4",
    # "Standard_E4d_v4",
    # "Standard_E4ds_v4",
    # "Standard_E4_v4",
    # "Standard_E4s_v4"
    # "Standard_M8ms"
    # "Standard_M208sv2" #Gen2 only
  ]
}

# EDIT AS NEEDED # 
# To account for any specific exclusions 

variable exclusions {
  default = {
    japaneast = "Standard_M8ms", 
    westeurope = "Standard_M8ms", 
    # centralus = "Standard_M8ms",  #core quota limits
    # northeurope = "Standard_M8ms", #core quota limits
    # westus2 = "Standard_M8ms", #core quota
    # eastus = "Standard_M8ms",  #core quota
    # eastus2 = "Standard_M8ms",  #core quota
    # southcentralus = "Standard_M8ms" #core quota limits
    # eastus = "Standard_M208sv2"
    }
  }

# EDIT AS NEEDED #
# Set the details for all the regions needed
# with the appropriate CIDR (/16) 

variable regioninfo {
  default = {
    westus2 = {
      zones = "1"
      cidr_net = "10.1.0.0"
    },
    eastus2 = {
      zones = "1"
      cidr_net = "10.2.0.0"
    },
    centralus = {
      zones = "1"
      cidr_net = "10.3.0.0"
    },
    eastus = {
      zones = "1"
      cidr_net = "10.4.0.0"
    },
    southcentralus = {
      zones = null
      cidr_net = "10.5.0.0"
    },
    japaneast = {
      zones = "3"
      cidr_net = "10.10.0.0"
    },
    northeurope = {
      zones = "1"
      cidr_net = "10.20.0.0"
    },
    westeurope = {
      zones = "1"
      cidr_net = "10.21.0.0"
    }
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


