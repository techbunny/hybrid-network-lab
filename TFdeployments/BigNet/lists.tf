# output "rg_instance_name" {
#     value = [
#         for instance in module.resourcegroup:
#         module.resourcegroup["westus2"].rg_name
#     ]
# }

variable "regioninfo2" {
type = list(map(string)) 
  default = [
    {
      region = "westus2"
      zones = "3"
      cidr_net = "10.1.0.0"
    },
    {
      region = "westcentralus"
      zones = "2"
      cidr_net = "10.2.0.0"
    },
    {
      region = "centralus"
      zones = "2"
      cidr_net = "10.3.0.0"
    }
  ]
  }


variable "vminfo2" {

  default = [
    {
      vm_size = "Standard_D2_v2",
      },
    {
      vm_size = "Standard_DS2_v2",
    },
    {
      vm_size = "Standard_D4_v3",

  }
  ]
}

output "vmsku" {
    value = [
        for index, x in var.regioninfo2: 
        merge(x, {"vm_size" = var.vminfo2[index].vm_size})
    ]
}