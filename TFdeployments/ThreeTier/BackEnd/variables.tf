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
    default = "Region1_BackEnd"
}

variable "region2_name" {
    default = "Region2_BackEnd"
}


variable "tags" {
  description = "ARM resource tags to any resource types which accept tags"
  type        = map(string)

  default = {
    application = "CoreCard"
  }
}