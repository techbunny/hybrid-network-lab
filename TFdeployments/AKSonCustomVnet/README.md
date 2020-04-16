# SingleVNET

This folder includes two subfolders, "supporting" and "AKS".  Each have Terraform deployments that can be run separately.  "Supporting" includes a VNET with two subnets, a VM and related storage account and a private DNS zone.

The "AKS" folder holds a template for a AKS deployment that uses one of the subnets from the supporting VNET.  The public DNS can be used to allow for custom DNS.  There is currently not support for adding records to a public DNS service even though it could be deployed.
 
