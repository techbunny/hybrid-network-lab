# Hybrid-Networking Lab

This template creates three VNETs in Azure, VNET1 and VNET2 are in the West region and are peered together.  VNET2 and VNET3 (East region) are connected using a Site to Site VPN.

VNET2 allows VNET1 to use gateway transit for access to VNET3. 

## Optional Modules

### Compute (Jumpbox)

### AKS

This module will deploy a 2-node Linux cluster into an existing VNET using the Azure network plugin (AzureCNI)