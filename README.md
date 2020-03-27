# Hybrid-Networking Lab

This folder includes a template that creates three VNETs in Azure, VNET1 and VNET2 are in the West region and are peered together.  VNET2 and VNET3 (East region) are connected using a Site to Site VPN.

VNET2 allows VNET1 to use gateway transit for access to VNET3. 

# SingleVNET

This folder includes two subfolders, "supporting" and "AKS".  Each have Terraform deployments that can be run separately.  "Supporting" includes a VNET with two subnets, a VM and related storage account and a private DNS zone.

The "AKS" folder holds a template for a AKS deployment that uses one of the subnets from the supporting VNET.  The public DNS can be used to allow for custom DNS.  There is currently not support for adding records to a public DNS service even though it could be deployed.
 

